include_recipe "percona::ruby"
include_recipe "database::mysql"

root_pw = Chef::EncryptedDataBagItem.load('passwords', 'mysql')["root"]
team_pw = Chef::EncryptedDataBagItem.load('passwords', 'mysql')["dashboard_web"]

app = search(:apps, "id:team_dashboard").first

env = node.chef_environment
env = 'development' if env == '_default'
if node[:active_applications] && node[:active_applications][:team_dashboard]
  env = node[:active_applications][:team_dashboard][:env] || env
end

domain = app["environments"][env]["domain"]
dbname = "team_dashboard_#{env}"

mysql_conn_info =  {:host => "localhost", :username => 'root', :password => root_pw }

mysql_database dbname do
  connection mysql_conn_info
  action :create
end

mysql_database_user 'dashboard_web' do
  connection mysql_conn_info 
  database_name dbname
  privileges [:all]
  host 'localhost'
  password team_pw
  action [:create,:grant]
end

execute "db_migrate" do
  cwd node[:team_dashboard][:path]
  command "rake db:migrate"
  action :nothing
end

template "#{node[:team_dashboard]}/config/database.yml" do
  source "database.yml.erb"
  variables :user => 'dashboard_web', :password => team_pw
  owner node[:team_dashboard][:user]
  group node[:team_dashboard][:group]
  mode 0600
  action :create_if_missing
  notifies :run, resources(:execute => "db_migrate"), :immediately
end

