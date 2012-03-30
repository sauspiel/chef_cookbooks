package "nagios-plugins"
package "nagios-nrpe-server"

gem_package "choice"

service "nagios-nrpe-server" do
  action :enable
  supports :restart => true, :reload => true
end

#directory "/u/nagios" do
#  owner "nagios"
#  group "nagios"
#  mode 00755
#  recursive true
#end

remote_directory node[:nagios][:extra_plugins_dir] do
  source "sauspiel_plugins"
  files_backup 5
  files_owner "nagios"
  files_group "nagios"
  files_mode 00755
  owner "nagios"
  group "nagios"
  mode 00755
end

template "/etc/nagios/nrpe_local.cfg" do
  source "nrpe_local.cfg.erb"
  notifies :restart, resources(:service => "nagios-nrpe-server")
  variables(:address => node[:ipaddress])
end

template "/etc/nagios/nrpe.d/commands.cfg" do
  source "nrpe_commands.cfg.erb"
  notifies :restart, resources(:service => "nagios-nrpe-server")
end
