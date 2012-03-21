require_recipe "nginx"
require_recipe "rails::app_dependencies"
require_recipe "unicorn"
require_recipe "bluepill"
require_recipe "users"
require_recipe "bundler"

if node[:active_applications]

  @apps = search(:apps, "*:*")
  
  directory "/etc/nginx/sites-include" do
    mode 0755
  end
  
  node[:active_applications].each do |name, conf|
  
    app = search(:apps, "id:#{name}").first

    app_root = "/u/apps/#{name}"
  
    domain = app["domain"]
    
    ssl_certificate domain
    
    other_apps = @apps.collect {|a| a['id']}.join("|")
    
    template "/etc/nginx/sites-available/#{full_name}" do
      source "multiapp_nginx.conf.erb"
      variables :app_name => name, :server_name => domain, :other_apps => other_apps
      notifies :reload, resources(:service => "nginx")
    end

    common_variables = {
      :preload => app[:preload] || true,
      :app_root => app_root,
      :app_name => name,
      :env => conf['env'],
      :user => "app",
      :group => "app",
      :listen_port => app[:listen_port] || 8600
    }

    template "#{node[:unicorn][:config_path]}/#{name}" do
      mode 0644
      cookbook "unicorn"
      source "unicorn.conf.erb"
      variables common_variables
    end

    template "#{node[:bluepill][:conf_dir]}/#{name}.pill" do
      mode 0644
      source "bluepill_unicorn.conf.erb"
      variables common_variables.merge(
        :interval => node[:rails][:monitor_interval],
        :memory_limit => app[:memory_limit] || node[:rails][:memory_limit],
        :cpu_limit => app[:cpu_limit] || node[:rails][:cpu_limit])
    end
    
    bluepill_service full_name do
      action [:enable, :load, :start]
    end
    
  end
end