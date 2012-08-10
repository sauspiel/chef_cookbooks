default.memcached[:conf_path] = "/etc/memcached.conf"
default.memcached[:max_memory] = 256
default.memcached[:max_connections] = 1024
default.memcached[:port] = 11211
default.memcached[:user] = "nobody"
default.memcached[:log_path] = "/var/log/memcached.log"