default[:rails][:asset_environment] = "production"
default[:rails][:worker_count] = 8
default[:rails][:app_server] = "unicorn"
default[:rails][:memory_limit] = '400' # megabytes
default[:rails][:monitor_interval] = '30' # seconds
default[:rails][:cpu_limit] = '50' # percent
default[:rails][:nginx_port] = 80
default[:rails][:keep_logs] = 10 # keep logs 10 days
