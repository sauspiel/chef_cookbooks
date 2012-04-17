default['munin']['sysadmin_email'] = "ops@example.com"
default['munin']['server_role'] = 'munin-server'
default['munin']['server_auth_method'] = 'openid'

default['munin']['basedir'] = "/etc/munin"
default['munin']['plugin_dir'] = "/usr/share/munin/plugins"
default['munin']['docroot'] = "/var/www/munin"
default['munin']['dbdir'] = "/var/lib/munin"
default['munin']['root']['group'] = "root"

default['munin']['plugins'] = "#{default['munin']['basedir']}/plugins"
default['munin']['tmpldir'] = "#{default['munin']['basedir']}/templates"
default['munin']['servername'] = node[:fqdn]
default.munin[:interface] = 'eth1'
