default.unicorn[:worker_count] = 6
default.unicorn[:timeout] = 10
default.unicorn[:version] = "4.0.1"
default.unicorn[:config_path] = "/etc/unicorn"
default.unicorn[:rundir] = "/var/run/unicorn"
default.unicorn[:user] = 'deploy'
default.unicorn[:group] = 'deploy'
