package "rsyslog" do
  action :install
end

service "rsyslog" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end

# default script uses "invoke-rc.d rsyslog rotate" action
# this creates a warning if /usr/sbin/policy-rc.d is present:
## /etc/cron.daily/logrotate:
## invoke-rc.d: action rotate is unknown, but proceeding anyway.
# as a workaround call `kill -SIGHUP <pidfile>` directly
template "/etc/logrotate.d/rsyslog" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode 0644
end
