default[:postgresql][:version] = "9.0"
default[:postgresql][:debversion] = "9.0.4-1+b1"
default[:postgresql][:deb_release] = "squeeze-backports"
# comma-separated, * means all
default[:postgresql][:listen_addresses] = "localhost"
default[:postgresql][:networks] = []
default[:postgresql][:port] = 5432
default[:postgresql][:shared_buffers] = "128kB"
default[:postgresql][:shmmax] = 33554432
default[:postgresql][:shmall] = 2097152
