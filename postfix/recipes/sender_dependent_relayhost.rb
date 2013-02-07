execute "postmap-sender_dependent_relayhost_maps" do
  command "postmap #{node[:postfix][:sender_dependent_relayhost_maps]}"
  action :nothing
end

template node[:postfix][:sender_dependent_relayhost_maps] do
  source "sender_dependent_relayhost.erb"
  owner "root"
  group "root"
  mode 0400
  notifies :run, resources(:execute => "postmap-sender_dependent_relayhost_maps"), :immediately
  notifies :reload, resources(:service => "postfix")
end
