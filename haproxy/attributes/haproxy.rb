default.haproxy[:user] = "haproxy"
default.haproxy[:group] = "haproxy"
default.haproxy[:connection_timeout] = "5s"
default.haproxy[:client_timeout] = "300s"
default.haproxy[:server_timeout] = "300s"
default.haproxy[:listen_port] = 80
default.haproxy[:admin_port] = 81
default.haproxy[:instances] = {}
