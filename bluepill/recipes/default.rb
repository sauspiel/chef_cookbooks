include_recipe "logrotate"

gem_package "bluepill" do
  version node[:bluepill][:version]
end

[node[:bluepill][:conf_dir], node[:bluepill][:log_dir], node[:bluepill][:pid_dir]].each do |dir|
  directory dir do
    owner "root"
    group "root"
  end
end

template "/etc/init.d/bluepill" do
  source "init.sh.erb"
  mode 0755
end

logrotate "bluepill" do
  files ["#{node[:bluepill][:log_dir]}/*.log"]
  frequency "daily"
  rotate_count 10
  compress true
  user 'root'
  group 'root'
  restart_command "/etc/init.d/bluepill restart > /dev/null" 
end

service "bluepill" do
  action [:enable, :start]
end
