include_recipe "munin::client"
require_recipe "nginx"

munin_servers = search(:node, "munin:[* TO *]")

if munin_servers.empty?
  Chef::Log.info("No munin nodes returned from search. Using this node so munin configuration has data.")
  munin_servers = Array.new
  munin_servers << node
end

munin_servers.sort! { |a,b| a[:fqdn] <=> b[:fqdn] }

package "munin"

cookbook_file "/etc/cron.d/munin" do
  source "munin-cron"
  mode "0644"
  owner "root"
  group node['munin']['root']['group']
  backup 0
end

template "#{node['munin']['basedir']}/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_servers, :docroot => node['munin']['docroot'], :contacts => node['munin']['contacts'])
end

template "#{node[:nginx][:dir]}/sites-available/munin.conf" do
  source "nginx.conf.erb"
  variables(:servername => node[:munin][:servername])
  mode 0644
end

nginx_site 'munin' do
  action :enable
end

directory node['munin']['docroot'] do
  recursive true
  owner "munin"
  group "munin"
  mode 0755
end
