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


servers = Array.new

node[:barman][:databases].each do |db|

  master = search(:node, "postgresql_role:master AND postgres_databases_#{db}_env:production").first
  x = Hash.new
  x[:id] = db 
  x[:ip] = master[:network][:interfaces][master[:postgresql][:interfaces].reject {|i| i == "lo" }.first][:addresses].select { |address, data| data[:family] == "inet"}[0][0]
  x[:name] = master[:fqdn]

  if servers.select { |f| f[:ip] == x[:ip] }.count == 0
    servers << x 
    directory "#{node[:barman][:home]}/#{db}" do
      owner 'barman'
      group 'barman'
      mode 0700
      action :create
    end
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
