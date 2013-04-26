include_recipe "bluepill"
include_recipe "repmgr::default"

template "#{node[:bluepill][:conf_dir]}/repmgrd.pill" do
  source "repmgrd.pill.erb"
  owner "root"
  group "root"
  mode 0644
  action node[:postgresql][:role].to_s == "slave" ? :create : :delete
end

bluepill_action = [:stop, :disable]
if node[:postgresql][:role].to_s == "slave"
  bluepill_action = [:enable, :load, :start]
end

bluepill_service "repmgrd" do
  action bluepill_action
end

