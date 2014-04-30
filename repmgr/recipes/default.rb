include_recipe 'postgresql'
include_recipe 'eye::default'

apt_package 'repmgr'

template "#{node[:repmgr][:config]}" do
  source "repmgr.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

directory '/etc/eye/root' do
  action :create
  recursive true
end

template "/etc/eye/root/repmgrd.eye" do
  source 'repmgrd.eye.erb'
  action node[:postgresql][:role].to_s == 'slave' ? :create : :delete
end

srv_action = node[:postgresql][:role].to_s == 'slave' ? [:enable, :load, :start] : [:stop, :disable] 
eye_service 'repmgrd' do
  supports [:start, :stop, :restart, :enable, :load, :reload]
  init_script_prefix ''
  action srv_action
end

include_recipe "repmgr::clear_history"
