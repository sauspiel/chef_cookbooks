include_recipe "munin::client"

munin_servers = search(:node, "munin:[* TO *]")

if munin_servers.empty?
  Chef::Log.info("No munin nodes returned from search. Using this node so munin configuration has data.")
  munin_servers = Array.new
  munin_servers << node
end

munin_servers.sort! { |a,b| a[:fqdn] <=> b[:fqdn] }

package "munin"

cookbook_file "/etc/cron.d/munin" do
  source "munin-cron"
  mode "0644"
  owner "root"
  group node['munin']['root']['group']
  backup 0
end

template "#{node['munin']['basedir']}/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_servers, :docroot => node['munin']['docroot'])
end

case node['munin']['server_auth_method']
when "openid"
  include_recipe "apache2::mod_auth_openid"
else
  template "#{node['munin']['basedir']}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner "munin"
    group node['apache']['group']
    mode 0640
    variables(
      :sysadmins => sysadmins
    )
  end
end

apache_site "000-default" do
  enable false
end

template "#{node[:apache][:dir]}/sites-available/munin.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables(:public_domain => public_domain, :docroot => node['munin']['docroot'])
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/munin.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

directory node['munin']['docroot'] do
  owner "munin"
  group "munin"
  mode 0755
end

apache_site "munin.conf"
