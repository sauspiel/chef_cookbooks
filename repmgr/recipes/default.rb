include_recipe "bluepill"

apt_package_hold 'repmgr' do
  version node[:repmgr][:version]
  default_release node[:repmgr][:release]
  action [:install, :hold]
end

template "#{node[:repmgr][:config]}" do
  source "repmgr.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

include_recipe "repmgr::clear_history"
