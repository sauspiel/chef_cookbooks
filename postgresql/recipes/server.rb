include_recipe "postgresql::default"

apt_package "postgresql-common" do
  default_release node[:postgresql][:deb_release]
  options "--force-yes -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""
end

Chef::Log.warn("Postgresql has to be stopped/started manually!")

# preventing postgresql from being started after installation
ruby_block "creating policy-rc.d file" do
  block do
    apt_create_policy_rc_d_file
  end
end

%w(postgresql postgresql-contrib).each do |pkg|
  apt_package_hold "#{pkg}-#{node[:postgresql][:version]}" do
    version node[:postgresql][:debversion]
    default_release node[:postgresql][:deb_release]
    action [:install, :hold]
    options "--force-yes"
  end
end

%w(libpq5 libpq-dev).each do |pkg|
  apt_package_hold pkg do
    version node[:postgresql][:debversion]
    default_release node[:postgresql][:deb_release]
    action [:install, :hold]
    options "--force-yes"
  end
end

%w(postgresql-server-dev postgresql-client).each do |pkg|
  apt_package_hold "#{pkg}-#{node[:postgresql][:version]}" do
    version node[:postgresql][:debversion]
    default_release node[:postgresql][:deb_release]
    action [:install, :hold]
    options "--force-yes"
  end
end

include_recipe "postgresql::pg_stat_plans"

# allowing start of postgresql again
ruby_block "deleting policy-rc.d file" do
  block do
    apt_remove_policy_rc_d_file
  end
end

%w(postgresql-common postgresql-client-common).each do |pkg|
  apt_package_hold pkg do
    default_release node[:postgresql][:deb_release]
    action [:hold]
  end
end

%w(libxslt1-dev libxml2-dev libpam0g-dev libedit-dev).each {|p| package p }

directory "/etc/postgresql" do
  mode 0755
  owner "postgres"
  group "postgres"
end


service "postgresql" do
  service_name "postgresql"
  supports :restart => true, :status => true, :reload => true
  action :nothing
end

instances = node[:postgresql][:instances] || Hash.new
instances["main"] = node[:postgresql] if instances.empty?

instances.each do |instance, instconfig|

  config = (instconfig.nil?) ? node[:postgresql].to_hash :  node[:postgresql].to_hash.merge(instconfig)
  config = config.each_with_object({}){|(k,v),h|h[k.to_sym] = v}

  datadir = "/var/lib/postgresql/#{node[:postgresql][:version]}/#{instance}"
  confdir = "/etc/postgresql/#{node[:postgresql][:version]}/#{instance}"

  [datadir, confdir].each do |dir|
    directory confdir do
      mode 0755
      owner "postgres"
      group "postgres"
    end
  end

  execute "creating database for #{instance}" do
    command "/usr/lib/postgresql/#{node[:postgresql][:version]}/bin/initdb -D #{datadir}"
    user "postgres"
    creates "#{datadir}/PG_VERSION"
    action :run
  end

  if node[:postgresql][:role]
    node.normal.postgresql.role = node[:postgresql][:role]
  end

  if node[:postgresql][:role] == "slave"
    directory "#{datadir}/pg_xlog_archive" do
      mode 0755
      owner "postgres"
      group "postgres"
    end
  end

  ['pg_hba.conf','pg_ident.conf'].each do |conf|
    template "#{confdir}/#{conf}" do
      source "#{conf}.erb"
      owner "postgres"
      group "postgres"
      mode 0644
    end
  end

  addresses = Array.new
  config[:interfaces].each do |eth|
    begin
      addresses <<  node[:network][:interfaces][eth][:addresses].select { |address,data| data["family"] == "inet"}[0][0]
    rescue
      Chef::Log.error("Interface #{eth} does not exist!")
    end
  end

  template "#{confdir}/postgresql.conf" do
    source "postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0644
    variables(:datadir => datadir, :confdir => confdir, :addresses => addresses, :instance => instance, :config => config)
  end

  template "#{confdir}/start.conf" do
    source "start.conf.erb"
    owner "postgres"
    group "postgres"
    mode 0644
    variables(:start => config[:start] || 'auto')
  end

  template "#{datadir}/archive_command.sh" do
    source "pg_archive_command.sh.erb"
    owner "postgres"
    group "postgres"
    mode 0700
    variables :cmd => config[:archive_command]
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

include_recipe "postgresql::user" if node[:postgresql][:manage_keys]

service "postgresql" do
  action [:enable, :start]
end
