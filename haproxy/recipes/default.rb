include_recipe "rsyslog"
include_recipe 'runit'

package 'haproxy'

directory "/etc/haproxy" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

directory "/var/log/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

directory "/var/run/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

template "/etc/haproxy/500.http"

# default rsyslog template is 50-default
# we don't want haproxy logs go to messages and syslog
# so haproxy config has to be loaded before default conf (49-haproxy.conf)

file "/etc/rsyslog.d/haproxy.conf" do
  action :delete
end

template "/etc/rsyslog.d/49-haproxy.conf" do
  owner "root"
  group "root"
  mode 0644
  source "rsyslog.conf.erb"
  notifies :restart, resources(:service => "rsyslog")
end

logrotate "haproxy" do
  files ["/var/log/haproxy/*.log"]
  frequency "daily"
  rotate_count 10
  compress true
  user node[:haproxy][:user]
  group node[:haproxy][:user]
  restart_command "restart rsyslog >/dev/null 2>&1 || true"
end

cookbook_file "/usr/local/bin/haproxy_runit_wrapper.sh" do
  mode 0755
end

runit_service "haproxy" do
  reload_command "/usr/bin/sv reload /etc/service/haproxy"
end
