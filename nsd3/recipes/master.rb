include_recipe "nsd3::default"

zones = Array.new
node[:dns][:domains].each do |domain|
  begin
    zones << data_bag_item("dns", domain.gsub(/\./, "_"))
  rescue
    Chef::Log.warn("No data bag found for domain #{domain}!")
  end
end

execute "nsdc_rebuild" do
  command "nsdc rebuild"
  action :nothing
end

execute "nsdc_reload" do
  command "nsdc reload"
  action :nothing
end

execute "nsdc_notify" do
  command "nsdc notify"
  action :nothing
end

zones.each do |zone|
  template "#{node[:nsd3][:zonesdir]}/#{zone['id']}" do
    source "zone.conf.erb"
    mode 0755
    owner "root"
    group "root"
    variables :zone => zone
    notifies :run, resources(:execute => "nsdc_rebuild")
    notifies :run, resources(:execute => "nsdc_reload")
    notifies :run, resources(:execute => "nsdc_notify")
  end
end



