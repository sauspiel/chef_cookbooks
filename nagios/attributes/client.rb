default.nagios[:allowed_hosts] = ["nms.sauspiel.de"]
default.nagios[:plugins_dir] = "/usr/lib/nagios/plugins"
default.nagios[:extra_plugins_dir] = "/usr/local/sauspiel/nagios/plugins"

# load average check: 5, 10 and 15 minute averages
default.nagios[:checks][:load][:enable] = true
default.nagios[:checks][:load][:warning] = "15,10,7"
default.nagios[:checks][:load][:critical] = "30,20,10"

# free memory
default.nagios[:checks][:free_memory][:enable] = true
default.nagios[:checks][:free_memory][:warning] = 250
default.nagios[:checks][:free_memory][:critical] = 150

# free disk space percentage
default.nagios[:checks][:free_disk][:enable] = true
default.nagios[:checks][:free_disk][:warning] = "8"
default.nagios[:checks][:free_disk][:critical] = "5"

# HAProxy
default.nagios[:checks][:haproxy_queue][:enable] = true
default.nagios[:checks][:haproxy_queue][:critical] = "10"
default.nagios[:checks][:haproxy_queue][:warning] = "1"

# HTTP error rates
default.nagios[:checks][:http_error_rate][:enable] = true
default.nagios[:checks][:http_error_rate][:critical] = "20"
default.nagios[:checks][:http_error_rate][:warning] = "15"

# Exceptions error rates
default.nagios[:checks][:exceptions_log_error_rate][:enable] = true
default.nagios[:checks][:exceptions_log_error_rate][:critical] = "30"
default.nagios[:checks][:exceptions_log_error_rate][:warning] = "10"

# swap
default.nagios[:checks][:swap][:enable] = true
default.nagios[:checks][:swap][:warning] = "60%"
default.nagios[:checks][:swap][:critical] = "30%"

# procs
default.nagios[:checks][:procs][:enable] = true
default.nagios[:checks][:procs][:warning] = 300
default.nagios[:checks][:procs][:critical] = 350

# uebersau
default.nagios[:checks][:uebersau][:enable] = true

# http
default.nagios[:checks][:http][:enable] = true

# gameserver
default.nagios[:checks][:gameserver][:enable] = true

# gameserver mem usage
default.nagios[:checks][:gameserver_memusage][:enable] = true
default.nagios[:checks][:gameserver_memusage][:warning] = 60
default.nagios[:checks][:gameserver_memusage][:critical] = 70 

# check mounts
default.nagios[:checks][:mounts][:enable] = true

# check root disk
default.nagios[:checks][:rootdisk][:enable] = true
default.nagios[:checks][:rootdisk][:warning] = "20%"
default.nagios[:checks][:rootdisk][:critical] = "10%"

# check sdb1
default.nagios[:checks][:sdb1][:enable] = true
default.nagios[:checks][:sdb1][:warning] = "20%"
default.nagios[:checks][:sdb1][:critical] = "10%"

# check sdc1
default.nagios[:checks][:sdc1][:enable] = true
default.nagios[:checks][:sdc1][:warning] = "20%"
default.nagios[:checks][:sdc1][:critical] = "10%"

# check mega raid sas
default.nagios[:checks][:megaraid_sas][:enable] = true

# check raid
default.nagios[:checks][:linux_raid][:enable] = true
