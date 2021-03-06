default.haproxy[:user] = "haproxy"
default.haproxy[:group] = "haproxy"
default.haproxy[:connection_timeout] = "5s"
default.haproxy[:client_timeout] = "300s"
default.haproxy[:server_timeout] = "300s"
default.haproxy[:listen_port] = 80
default.haproxy[:admin_port] = 81
default.haproxy[:instances] = {}
default.haproxy[:ssl_default_bind_ciphers] = 'EECDH+AES128:EECDH+AES256:RSA+AES128:RSA+AES256:DES-CBC3-SHA'
