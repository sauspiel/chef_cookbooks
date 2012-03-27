execute "start-runsvdir" do
  command "start runsvdir"
  action :nothing
end

execute "runit-hup-init" do
  command "telinit q"
  only_if "grep ^SV /etc/inittab"
  action :nothing
end

directory node[:runit_service_dir] do
  mode 0755
  recursive true
  action :create
end
  
package "runit" do
  action :install
  notifies :run, resources(:execute => node[:platform_family] == "debian" ? "runit-hup-init" : "start-runsvdir")
end