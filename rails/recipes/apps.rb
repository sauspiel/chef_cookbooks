include_recipe "nginx"
include_recipe "rails::app_dependencies"
include_recipe "unicorn"
include_recipe "bluepill"
include_recipe "users"
include_recipe "bundler"
include_recipe "logentries"

if node[:active_applications]

  @apps = search(:apps, "*:*")
  
  directory "/etc/nginx/sites-include" do
    mode 0755
  end
  
  directory "/etc/nginx/sites-available" do
      mode 0755
  end 

  ["/var/www", "/var/run/unicorn"].each do |dir|
    directory dir do
      owner "deploy"
      group "deploy"
    end
  end
    
  node[:active_applications].each do |name, conf|
  
    app = search(:apps, "id:#{name}").first

    domain = app["environments"][conf["env"]]["domain"]

    app_root = "/var/www/#{domain}"

    ssl = app["environments"][conf["env"]]["ssl"].nil? || app["environments"][conf["env"]]["ssl"] == true
    
    ssl_certificate domain if ssl
    
    other_apps = @apps.collect {|a| a['id'] unless a['id'] == name }.compact.sort.join("|")

    htpasswd = nil
    if app["environments"][conf["env"]]["htpasswd"]
      htpasswd = Hash.new
      htpasswd[:user] = app["environments"][conf["env"]]["htpasswd"]
      htpasswd[:passwd] = Chef::EncryptedDataBagItem.load("passwords", "http")[htpasswd[:user]].crypt("salt")
    end

    if htpasswd
      template "/etc/nginx/htpasswd.d/#{name}.htpasswd" do
        source "htpasswd.erb"
        variables :htpasswd => htpasswd
        owner node[:nginx][:user]
        group node[:nginx][:group]
        mode 0600
      end
    end

    template "/etc/nginx/sites-available/#{name}.conf" do
      source "multiapp_nginx.conf.erb"
      variables :app_name => name, :server_name => domain, :other_apps => other_apps, :htpasswd => htpasswd, :ssl => ssl
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
      restart_command "/bin/kill -USR1 `cat #{app_root}/current/tmp/unicorn/unicorn.pid` > /dev/null"
    end
    
    execute "follow production log" do
      command "le follow #{app_root}/current/log/production.log --name #{name}-production"
      not_if "le whoami | grep #{name}-production"
    end
    
    execute "follow nginx access log" do
      command "le follow /var/log/nginx/#{domain}.access.log --name #{name}-nginx-access"
      not_if "le whoami | grep #{name}-nginx-access"
    end
    
    # deleting old logrotate entries for rails apps
    file "/etc/logrotate.d/rails" do
      action :delete
      only_if { File.exists?("/etc/logrotate.d/rails")}
    end
  end
end
