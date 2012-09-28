include_recipe "postgresql::client"


apt_package "postgresql-common" do
  default_release node[:postgresql][:deb_release]
end

%w(postgresql postgresql-server-dev postgresql-contrib).each do |pkg|
  apt_package "#{pkg}" do
    version node[:postgresql][:debversion]
    default_release node[:postgresql][:deb_release]
  end
end

%w(libxslt1-dev libxml2-dev libpam0g-dev libedit-dev).each {|p| package p }

#remote_file "/tmp/postgresql-repmgr-9.0_1.0.0.deb" do
#  source "#{node[:package_url]}/postgresql-repmgr-9.0_1.0.0.deb"
#  not_if { File.exists?("/tmp/postgresql-repmgr-9.0_1.0.0.deb") }
#end

#dpkg_package "postgresql-repmgr" do
#  source "/tmp/postgresql-repmgr-9.0_1.0.0.deb"
#  only_if { File.exists?("/tmp/postgresql-repmgr-9.0_1.0.0.deb") }
#end

directory "/etc/postgresql" do
  mode 0755
  owner "postgres"
  group "postgres"
end

datadir = "/var/lib/postgresql/#{node[:postgresql][:version]}/main"

if node[:postgresql][:role] == "slave"
  directory "#{datadir}/pg_xlog_archive" do
    mode 0755
    owner "postgres"
    group "postgres"
  end
end

service "postgresql" do
  service_name "postgresql"
  supports :restart => true, :status => true, :reload => true
  action :nothing
end

confdir = "/etc/postgresql/#{node[:postgresql][:version]}/main"

template "#{confdir}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0644
  notifies :reload, resources(:service => "postgresql")
end

addresses = Array.new
node[:postgresql][:interfaces].each do |eth|
  addresses <<  node[:network][:interfaces]["eth"][:addresses].select { |address,data| data["family"] == "inet"}[0][0]
end

template "#{confdir}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0644
  variables(:datadir => datadir, :confdir => confdir, :addresses => addresses)
  
  # disabled to prevent accidental restarts in production
  # notifies :restart, resources(:service => "postgresql")
end


if node[:postgresql][:role] == "slave"
  template "#{datadir}/recovery.conf" do
    source "recovery.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0644
    
    # disabled to prevent accidental restarts in production    
    # notifies :restart, resources(:service => "postgresql")
  end  
else
  file "#{datadir}/recovery.conf" do
    action :delete
  end
end

template "/etc/sysctl.d/30-postgresql-shm.conf" do
  source "30-postgresql-shm.conf.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/init.d/postgres_perf" do
  source "postgres_perf.init.sh.erb"
  owner "root"
  group "root"
  mode 0755
end

service "postgres_perf" do
  action [:enable, :start]
end

service "postgresql" do
  action [:enable, :start]
end
