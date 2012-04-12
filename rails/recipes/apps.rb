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
  
  directory "/etc/nginx/sites-available" do
      mode 0755
  end 

  
  node[:active_applications].each do |name, conf|
  
    app = search(:apps, "id:#{name}").first

    domain = app["environments"][conf["env"]]["domain"]

    app_root = "/var/www/#{domain}"  
    
    ssl_certificate domain
    
    other_apps = @apps.collect {|a| a['id'] unless a['id'] == name }.compact.sort.join("|")
    
    template "/etc/nginx/sites-available/#{name}.conf" do
      source "multiapp_nginx.conf.erb"
      variables :app_name => name, :server_name => domain, :other_apps => other_apps
      notifies :reload, resources(:service => "nginx")
    end

    common_variables = {
      :preload => app[:preload] || true,
      :app_root => app_root,
      :app_name => name,
      :env => conf['env'],
      :user => "deploy",
      :group => "deploy",
      :worker_count => app["environments"][conf["env"]]["worker_count"] || node[:unicorn][:worker_count],
      :listen_port => app[:listen_port] || 8600
    }

    template "#{node[:unicorn][:config_path]}/#{name}.conf.rb" do
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
    
    bluepill_service name do
      action [:enable, :load, :start]
    end
    
    nginx_site name do
      action :enable
    end
    
    logrotate name do
      files ["#{app_root}/current/log/*.log"]
      frequency "daily"
      rotate_count 10
      compress true
      user 'deploy'
      group 'deploy'
      restart_command "kill -USR1 `cat #{app_root}/current/tmp/unicorn/unicorn.pid` > /dev/null"
    end
  end
end
