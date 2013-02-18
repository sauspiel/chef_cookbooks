include_recipe "percona::ruby"
include_recipe "database::mysql"

root_pw = Chef::EncryptedDataBagItem.load('passwords', 'mysql')["root"]
team_pw = Chef::EncryptedDataBagItem.load('passwords', 'mysql')["dashboard_web"]

app = search(:apps, "id:team_dashboard").first

env = node.chef_environment
env = 'development' if env == '_default'

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
