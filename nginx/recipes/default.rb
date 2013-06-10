include_recipe "apt"
include_recipe "ssl_certificates"

apt_repository "nginx" do
  uri "http://nginx.org/packages/debian"
  components ["nginx"]
  distribution node[:lsb][:codename]
  key "http://nginx.org/keys/nginx_signing.key"
  action :add
end

if !node[:nginx][:with_pam_authentication]
  apt_package_hold "nginx" do
    version node[:nginx][:version]
    default_release node[:nginx][:debian_release]
    action [:install, :hold]
  end

else
  # see https://github.com/sauspiel/hosting/wiki/Nginx
  apt_package_hold "nginx" do
    version "#{node[:nginx][:version]}+authpam1"
    default_release node[:nginx][:debian_release]
    action [:install, :hold]
  end

  group "shadow" do
    members node[:nginx][:user]
    append true
  end
end

group "ssl-cert" do
  members node[:nginx][:user]
  append true
end

template "/etc/logrotate.d/nginx" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode 00644
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w(sites-available sites-enabled helpers sites-include common htpasswd.d).each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    action :create
  end
end

template "#{node[:nginx][:dir]}/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "nginx")
end

template "#{node[:nginx][:dir]}/common/proxy.conf" do
  source "proxy.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "nginx")
end

# helpers to be included in your vhosts
node[:nginx][:helpers].each do |h|
  template "/etc/nginx/helpers/#{h}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end

if !node[:nginx][:with_default_site]
  file "#{node[:nginx][:dir]}/conf.d/default.conf" do
    action :delete
    notifies :reload, resources(:service => "nginx")
  end
else
  template "#{node[:nginx][:dir]}/conf.d/default.conf" do
    source "default.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :reload, resources(:service => "nginx")
    variables(:with_stats => node[:nginx][:with_stats])
  end
end

# server-wide defaults, automatically loaded
node[:nginx][:extras].each do |ex|
  template "#{node[:nginx][:dir]}/conf.d/#{ex}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end  

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

service "nginx" do
  action [ :enable, :start ]
end
