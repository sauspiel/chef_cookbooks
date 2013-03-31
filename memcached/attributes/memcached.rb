default.memcached[:conf_path] = "/etc/memcached.conf"
default.memcached[:max_memory] = 256
default.memcached[:max_connections] = 1024
default.memcached[:port] = 11211
default.memcached[:user] = "nobody"
default.memcached[:log_path] = "/var/log/memcached.log"
default.memcached[:bind_address] = "127.0.0.1"
default.memcached[:slab_page_size] = "10m"
