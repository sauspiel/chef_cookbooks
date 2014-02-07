apt_package 'redis-server' do
  action :install
end

service "redis-server" do
  provider Chef::Provider::Service::Insserv
  action [:disable, :stop]
end
