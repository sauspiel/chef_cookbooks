include_recipe "logrotate"
include_recipe "bluepill"

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

template "#{node[:nsd3][:confdir]}/zones.conf" do
  source "zones.conf.erb"
  mode 0755
  owner "root"
  group "root"
  variables :zones => zones
end

template "#{node[:nsd3][:confdir]}/nsd.conf" do
  source "nsd.conf.erb"
  mode 0755
  owner "root"
  group "root"
end


logrotate "nsd3" do
  files ["#{node[:nsd3][:logfile]}"]
  frequency "daily"
  rotate_count 3 
  compress true
  user 'nsd'
  group 'nsd'
  restart_command "/usr/sbin/nsdc reload"
end

service "nsd3" do
  action [:enable, :restart] 
end

template "#{node[:bluepill][:conf_dir]}/nsd3.pill" do
  source "nsd3.pill.erb"
  owner "root"
  group "root"
  mode 0644
  variables :owner => "root", :group => "root", :pid => node[:nsd3][:pid]
end

bluepill_service "nsd3" do
  action [:load, :start]
end
