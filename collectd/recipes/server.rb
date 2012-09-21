include_recipe "collectd::default"

file "#{node[:collectd][:conf_dir]}/conf.d/network.conf" do
  action :delete
end

collectd_plugin "network" do
  config :listen=>'0.0.0.0'
  name "network_server"
  type "network"
end
