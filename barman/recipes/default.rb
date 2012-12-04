apt_repository "pgdg" do
  uri "http://pgapt.debian.net" 
  distribution "squeeze-pgdg"
  components ["main"]
  keyserver "keys.gnupg.net"
  key "ACCC4CF8"
  action :add
end


%w(python-psycopg2 python-argh python-dateutil python-argparse barman).each do |pkg|
  package pkg do
    action :install
  end
end

directory node[:barman][:log_dir] do
  owner 'barman'
  group 'barman'
  mode 0755
  action :create
end  

logfile = "#{node[:barman][:log_dir]}/barman.log"

logrotate "barman" do
  files ["#{node[:barman][:log_dir]}/*.log"]
  frequency "daily"
  rotate_count 10
  compress true
  user 'barman'
  group 'barman'
end


servers = barman_master_servers
servers.each do |srv|
  directory "#{node[:barman][:home]}/#{srv[:id]}" do
    owner 'barman'
    group 'barman'
    mode 0700
    action :create
  end
end

include_recipe "barman::user" if node[:barman][:manage_keys]

template node[:barman][:config] do
  source "barman.conf.erb"
  owner 'barman'
  group 'barman'
  mode 0700
  variables :servers => servers , :logfile => logfile
end
