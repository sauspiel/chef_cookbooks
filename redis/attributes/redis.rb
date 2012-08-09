default.redis[:root_path] = "/var/lib/redis"
default.redis[:port] = 6379
default.redis[:bind_address] = "127.0.0.1"
default.redis[:timeout] = 300
# max memory in MB
default.redis[:max_memory] = "250"

default.redis[:data_directory] = "/var/lib/redis"
default.redis[:pid_path] = "/var/run/redis.pid"
default.redis[:log_path] = "/var/log/redis/redis-server.log"
default.redis[:syslog] = true
# default to full durability persistence
default.redis[:appendonly] = true
