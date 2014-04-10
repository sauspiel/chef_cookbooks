include_recipe "logrotate"

package "dnsutils"

package "nsd3" do
  action :upgrade
end

directory node[:nsd3][:zonesdir] do
  mode 0775
  owner "root"
  group "nsd"
end

directory node[:nsd3][:run_dir] do
  mode 0755
  owner "nsd"
  group "nsd"
end

service "nsd3" do
  supports [:enable, :restart]
  action :enable
end

zones = Array.new
node[:dns][:domains].each do |domain|
  begin
    zones << data_bag_item("dns", domain.gsub(/\./, "_"))
  rescue
    Chef::Log.warn("No data bag found for domain #{domain}!")
  end
end

template "#{node[:nsd3][:confdir]}/zones.conf" do
  source "zones.conf.erb"
  mode 0755
  owner "root"
  group "root"
  variables :zones => zones
  notifies :restart, resources(:service => "nsd3")
end

template "#{node[:nsd3][:confdir]}/nsd.conf" do
  source "nsd.conf.erb"
  mode 0755
  owner "root"
  group "root"
  notifies :restart, resources(:service => "nsd3")
end

template '/etc/logrotate.d/nsd3' do
  source 'logrotate.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables frequency: 'daily',
    rotate_count: 3,
    user: 'nsd',
    group: 'nsd'
end
