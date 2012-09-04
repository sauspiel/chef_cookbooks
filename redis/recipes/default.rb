package 'redis-server' do
  version node[:redis][:version]
  action :install
end

service "redis-server" do
  provider Chef::Provider::Service::Insserv
  action [:disable, :stop]
end
