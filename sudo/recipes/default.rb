include_recipe 'users'

package "sudo" do
  action :upgrade
  options "--force-yes -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\""
end

directory "/etc/sudoers.d" do
  mode 0755
  owner 'root'
  group 'root'
  action :create
end

cookbook_file "/etc/sudoers.d/README" do
  cookbook "sudo"
  source "README.sudoers"
  mode 0440
  owner "root"
  group "root"
  action :create
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  sudogroups = 
  variables(:sudoers_groups => node[:active_sudo_groups], :sudoers_users => node[:active_sudo_users])
end
