include_recipe "bluepill"
include_recipe "repmgr::default"

template "#{node[:bluepill][:conf_dir]}/repmgrd.pill" do
  source "repmgrd.pill.erb"
  owner "root"
  group "root"
  mode 0644
end

bluepill_service "repmgrd" do
  action [:enable]
end

