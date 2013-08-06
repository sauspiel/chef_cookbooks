include_recipe "team_dashboard::database"

%w(libxml2 libxml2-dev libxslt1.1 libxslt1-dev).each do |pkg|
  package pkg
end

db_password = Chef::EncryptedDataBagItem.load('passwords', 'mysql')["dashboard_web"]
app = search(:apps, "id:team_dashboard").first
env = node.chef_environment
env = 'development' if env == '_default'

htpasswd = nil
if app["environments"][env]["htpasswd"]
  user = app["environments"][env]["htpasswd"]
  pw = Chef::EncryptedDataBagItem.load("passwords", "http")[user].crypt("salt")
  htpasswd = { 
    :user => user,
    :passwd => pw }

  template "#{node[:nginx][:dir]}/htpasswd.d/team_dashboard.htpasswd" do
    source "htpasswd.erb"
    variables :htpasswd => htpasswd
    owner node[:nginx][:user]
    group node[:nginx][:group]
    mode 0600
  end
end

%w{config}.each do |dir|
  directory "#{node[:team_dashboard][:path]}/shared/#{dir}" do
    owner "deploy"
    group "deploy"
    mode 0700
    recursive true
    action :create
  end
end

application "team_dashboard" do
  path node[:team_dashboard][:path]
  repository node[:team_dashboard][:repository]
  scm_provider Chef::Provider::Git
  owner "deploy"
  group "deploy"
  revision node[:team_dashboard][:repository_revision]
  environment_name env
  enable_submodules true
  migrate true
  shallow_clone false
  action :deploy

  rails do
    bundler true
    bundler_deployment false
    database do
      database "team_dashboard_#{env}"
      username "dashboard_web"
      password db_password
      adapter "mysql2"
      host "localhost"
    end
  end

  unicorn_bp do
    worker_processes 2
    preload_app true
    worker_timeout 300
    environment_vars :GRAPHITE_URL => node[:team_dashboard][:graphite_url]
  end

  
  nginx do
    cookbook "team_dashboard"
    template "nginx.conf.erb"
    variables :app_name => "team_dashboard", 
      :domain => app["environments"][env]["domain"],
      :htpasswd => htpasswd
  end
end
