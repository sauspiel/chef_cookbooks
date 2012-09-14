include_recipe "collectd::default"

collectd_plugin "network" do
  config :listen=>'0.0.0.0'
  name "network_server"
  type "network"
end
