include_recipe "nginx"
include_recipe "rails::app_dependencies"
include_recipe "unicorn"
include_recipe "bluepill"
include_recipe "users"
include_recipe "bundler"

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

  if node[:active_applications].count > 1 && (node[:rails].nil? || node[:rails][:default_domain].nil?)
    Chef::Log.warn("Please set node[:rails][:default_domain]!")
  end
    
  node[:active_applications].each do |name, conf|

    environment = conf["env"] || node.chef_environment

    app = search(:apps, "id:#{name}").first

    domain = app["environments"][environment]["domain"]

    app_root = "/var/www/#{domain}"

    includes = app["environments"][environment]["includes"] || Array.new

    certificate_name = app["environments"][environment]["ssl_certificate"]

    ssl_certificate certificate_name if certificate_name
    
    other_apps = @apps.collect {|a| a['id'] unless a['id'] == name }.compact.sort.join("|")

    htpasswd = nil
    if app["environments"][environment]["htpasswd"]
      htpasswd = Hash.new
      htpasswd[:user] = app["environments"][environment]["htpasswd"]
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

    set_default_domain = false
    
    if node[:active_applications].count == 1
      set_default_domain = true
    else
      if !node[:rails].nil? && !node[:rails][:default_domain].nil?
        set_default_domain = domain.to_s.eql?(node[:rails][:default_domain].to_s)
      end
    end

    template "/etc/nginx/sites-available/#{name}.conf" do
      source "multiapp_nginx.conf.erb"
      variables :app_name => name, 
        :server_name => domain, 
        :other_apps => other_apps, 
        :htpasswd => htpasswd, 
        :certificate_name => ssl_certificate_as_wildcard(certificate_name), 
        :set_default_domain => set_default_domain, 
        :includes => includes,
        :behind_ssl_proxy => app["environments"][environment]["behind_ssl_proxy"] || false
      notifies :reload, resources(:service => "nginx")
    end

    unicorn_cmd = "/usr/bin/env RAILS_ENV=#{environment} #{node[:languages][:ruby][:bin_dir]}/"
    if app["environments"][environment]["cmd"].eql?('unicorn_rails')
      unicorn_cmd = unicorn_cmd + "unicorn_rails"
    else
      unicorn_cmd = unicorn_cmd + "bundle exec unicorn #{app_root}/current/config.ru "
    end

    unicorn_cmd = unicorn_cmd + " -Dc #{node[:unicorn][:config_path]}/#{name}.conf.rb -E #{environment}"
    common_variables = {
      :preload => app[:preload] || true,
      :app_root => "#{app_root}/current",
      :app_name => name,
      :env => conf['env'],
      :user => "deploy",
      :group => "deploy",
      :worker_count => app["environments"][environment]["worker_count"] || node[:unicorn][:worker_count],
      :listen_port => app[:listen_port] || 8600,
      :unicorn_cmd => unicorn_cmd
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
      rotate_count node[:rails][:keep_logs]
      compress true
      user 'deploy'
      group 'deploy'
      restart_command "/bin/kill -USR1 `cat #{app_root}/current/tmp/unicorn/unicorn.pid` > /dev/null"
    end
    
    if rails_with_logentries?(app, environment)
      include_recipe "logentries"
      execute "follow #{environment} log" do
        command "le follow #{app_root}/current/log/#{environment}.log --name #{name}-#{environment}"
        not_if "le whoami | grep #{name}-#{environment}"
        ignore_failure true
      end
      
      execute "follow nginx access log" do
        command "le follow /var/log/nginx/#{domain}.access.log --name #{name}-nginx-access"
        not_if "le whoami | grep #{name}-nginx-access"
        ignore_failure true
      end
    end

    
    # deleting old logrotate entries for rails apps
    file "/etc/logrotate.d/rails" do
      action :delete
      only_if { File.exists?("/etc/logrotate.d/rails")}
    end
  end
end
