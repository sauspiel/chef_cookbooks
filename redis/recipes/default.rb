package 'redis-server' do
  version node[:redis][:version]
  action :install
end

service "redis-server" do
  action :stop
end

execute "disabling redis-server service" do
  command "/usr/sbin/update-rc.d -f redis-server remove >/dev/null 2>&1"
  action :run
  ignore_failure true
end



