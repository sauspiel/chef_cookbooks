package "openssh-server"

service "ssh" do
  supports :restart => true, :reload => true
  action :enable
end

nodes = search(:node, "*:*")

addresses = []
if !node[:ssh][:interfaces].nil?
  node[:ssh][:interfaces].each do |interface|
    if node[:network][:interfaces].has_key? interface
      addresses << node[:network][:interfaces][interface][:addresses].select { |address, data| data["family"] == "inet"}[0][0]
    end
  end
else
  if !node[:ssh][:addresses].nil?
    addresses = node[:ssh][:addresses]
  else
    node[:network][:interfaces].each do |iface, addrs|
      addrs[:addresses].each do |ip, params|
        addresses << ip if params[:family].eql?('inet')
      end
    end
  end
end

if addresses.count == 0
  addresses << "0.0.0.0"
end


template "/etc/ssh/known_hosts" do
  source "known_hosts.erb"
  mode 0644
  owner "root"
  group "root"
  variables(:nodes => nodes)
end

template "/etc/ssh/ssh_config" do
  source "ssh_config.erb"
  mode 0644
  owner "root"
  group "root"
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "ssh")
  variables(:addresses => addresses) 
end


service "ssh" do
  action :start
end
