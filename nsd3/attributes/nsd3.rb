default.nsd3[:confdir] = "/etc/nsd3"
default.nsd3[:zonesdir] = "#{node.nsd3[:confdir]}/zones.d"
default.nsd3[:logfile] = "/var/log/nsd3.log"
default.nsd3[:type] = "default"
default.nsd3[:tcpcount] = 100
default.nsd3[:statistics] = 10
default.nsd3[:pid] = "/var/run/nsd3/nsd.pid"
