include_recipe "rsyslog"

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

template "/etc/rsyslog.d/haproxy.conf" do
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
