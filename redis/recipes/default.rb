package 'redis-server' do
  version node[:redis][:version]
  action :install
end
