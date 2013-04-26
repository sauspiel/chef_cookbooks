include_recipe "collectd"
include_recipe "repmgr::default"


collectd_plugin "postgres-slave" do
  template "collectd.erb"
  cookbook "repmgr"
  config :user => node[:repmgr][:user], 
          :cluster => node[:repmgr][:cluster], 
          :host => node[:repmgr][:host], 
          :dbname => node[:repmgr][:dbname],
          :node => node[:repmgr][:node]
  action node[:postgresql][:role].to_s == "slave" ? :create : :delete
end
