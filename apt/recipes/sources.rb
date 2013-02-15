execute "apt_get_update" do
  command "apt-get update"
  action :nothing
  ignore_failure true
end

template "/etc/apt/sources.list" do
  source "sources.list.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:sources => node[:apt][:sources])
  notifies :run, resources(:execute => "apt_get_update"), :immediately
end

template "/etc/apt/preferences" do
  source "preferences.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:sources => node[:apt][:sources])
  notifies :run, resources(:execute => "apt_get_update"), :immediately
end
