require_recipe "apt"

if !node[:nginx][:with_pam_authentication]
  apt_repository "nginx" do
    uri "http://nginx.org/packages/debian"
    components ["nginx"]
    distribution node[:lsb][:codename]
    keyserver "keyserver.ubuntu.com"
    key "ABF5BD827BD9BF62"
    action :add
  end

  package "nginx" do
    version node[:nginx][:version]
    action :install
  end

else
  # see https://github.com/sauspiel/hosting/wiki/Nginx
  tmp = node[:tmp] ? node[:tmp] : "/tmp"
  pamversion = "#{node[:nginx][:version]}+authpam1"
  deb = "nginx_#{pamversion}_amd64.deb"
  debpath = "#{tmp}/#{deb}"

  remote_file "#{debpath}" do
    version = pamversion
    source "#{node[:package_url]}/#{deb}"
    not_if { File.exists?("#{debpath}")}
  end

  dpkg_package "nginx_with_pam" do
    source "#{debpath}"
    action :install
    only_if { File.exists?("#{debpath}")}
  end

  group "shadow" do
    members node[:nginx][:user]
    append true
  end
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

%w(sites-available sites-enabled helpers site-include common).each do |dir|
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

# server-wide defaults, automatically loaded
node[:nginx][:extras].each do |ex|
  template "/etc/nginx/conf.d/#{ex}.conf" do
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
