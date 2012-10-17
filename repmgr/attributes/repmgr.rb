default[:repmgr][:config] = '/etc/repmgr.conf'
default[:repmgr][:cluster] = 'test'
default[:repmgr][:node] = 1
default[:repmgr][:user] = 'repmgr'
default[:repmgr][:dbname] = 'postgres'
default[:repmgr][:host] = node[:fqdn].split(".")[0]
default[:repmgr][:log] = '/var/log/repmgrd.log'
