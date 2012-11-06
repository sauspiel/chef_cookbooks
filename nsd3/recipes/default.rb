package "dnsutils"

package "nsd3" do
  action :upgrade
end

directory node[:nsd3][:zonesdir] do
  mode 0755
  owner "root"
  group "root"
end

zones = Array.new
node[:dns][:domains].each do |domain|
  begin
    zones << data_bag_item("dns", domain.gsub(/\./, "_"))
  rescue
    Chef::Log.warn("No data bag found for domain #{domain}!")
  end
end

template "#{node[:nsd3][:confdir]}/nsd.conf" do
  source "nsd.conf.erb"
  mode 0755
  owner "root"
  group "root"
  variables :zones => zones
end

serial = Time.new.strftime("%y%m%d%H%M")
zones.each do |zone|
  template "#{node[:nsd3][:zonesdir]}/#{zone['id']}" do
    source "zone.conf.erb"
    mode 0755
    owner "root"
    group "root"
    variables :zone => zone, :serial => serial
  end
end

execute "rebuild" do
  command "nsdc rebuild"
  action :run
end

service "nsd3" do
  action [:enable, :restart] 
end
