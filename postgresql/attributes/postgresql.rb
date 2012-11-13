default[:postgresql][:version] = "9.0"
default[:postgresql][:debversion] = "9.0.4-1+b1"
default[:postgresql][:deb_release] = "squeeze-backports"
default[:postgresql][:interfaces] = []
default[:postgresql][:networks] = []
default[:postgresql][:port] = 5432
default[:postgresql][:shared_buffers] = "128kB"
default[:postgresql][:shmmax] = 33554432
default[:postgresql][:shmall] = 2097152
default[:postgresql][:blockdev] = {}
default[:postgresql][:log_language] = "en_US.UTF-8"
default[:postgresql][:lc_language] = "en_US.UTF-8"
default[:postgresql][:text_search_config] = "pg_catalog.english"
default[:postgresql][:datestyle] = 'iso, dmy'
default[:postgresql][:max_connections] = 100
default[:postgresql][:wal_level] = "hot_standby"
default[:postgresql][:max_wal_senders] = 5
default[:postgresql][:wal_keep_segments] = 32
default[:postgresql][:hot_standby] = "on" 
default[:postgresql][:archive_command] = "/bin/true"
default[:postgresql][:archive_mode] = "on"
default[:postgresql][:archive_timeout] = 180
default[:postgresql][:superuser_reserved_connections] = 10
default[:postgresql][:ssl] = false
default[:postgresql][:temp_buffers] = "8MB"
default[:postgresql][:work_mem] = "64kB"
default[:postgresql][:maintenance_work_mem] = "1MB"
default[:postgresql][:effective_io_concurrency] = 1
default[:postgresql][:fsync] = "off"
default[:postgresql][:synchronous_commit] = "off"
default[:postgresql][:commit_delay] = 0
default[:postgresql][:commit_siblings] = 5
default[:postgresql][:checkpoint_segments] = 16
default[:postgresql][:log_min_duration_statement] = 2000
default[:postgresql][:autovacuum_max_workers] = 3
default[:postgresql][:autovacuum_naptime] = "1min"
default[:postgresql][:with_repmgr] = true
default[:postgresql][:timezone] = "GMT"
default[:postgresql][:log_lock_waits] = "on"
default[:postgresql][:max_standby_streaming_delay] = 30
default[:postgresql][:max_standby_archive_delay] = 30
default[:postgresql][:log_checkpoints] = "on"
default[:postgresql][:wal_sync_method] = "fdatasync"
