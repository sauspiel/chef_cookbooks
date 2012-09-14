include_recipe "collectd::default"

collectdservers = node[:collectd][:servers]
if collectdservers.empty?
  search(:node, 'recipes:collectd\:\:server') do |n|
    collectdservers << n[:fqdn]
  end
end

if collectdservers.empty?
  raise "No servers found. Please configure at least one node with collectd::server."
end

collectd_plugin "network" do
  config :server => collectdservers
end
