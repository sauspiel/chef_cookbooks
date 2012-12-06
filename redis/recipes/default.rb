apt_package_hold 'redis-server' do
  version node[:redis][:version]
  action [:install, :hold]
end

service "redis-server" do
  provider Chef::Provider::Service::Insserv
  action [:disable, :stop]
end
