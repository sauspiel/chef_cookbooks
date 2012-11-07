include_recipe "nsd3::default"

zones = Array.new
node[:dns][:domains].each do |domain|
  begin
    zones << data_bag_item("dns", domain.gsub(/\./, "_"))
  rescue
    Chef::Log.warn("No data bag found for domain #{domain}!")
  end
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

execute "nsdc rebuild" do
  command "nsdc rebuild"
  action :run
end

execute "nsdc reload" do
  command "nsdc reload"
  action :run
end

execute "nsdc notify" do
  command "nsdc notify"
  action :run
end

