actions :add

def initialize(*args)
  super
  @action = :add
end

attribute :name, :kind_of => String, :name_attributes => true

attribute :mode , :kind_of => String, :default => "tcp"
attribute :maxconn, :kind_of => Integer, :default => 1024
attribute :global_timeout_connect, :kind_of => String, :default => "5s"
attribute :global_timeout_client, :kind_of => String, :default => "1h"
attribute :global_timeout_server, :kind_of => String, :default => "1h"
attribute :ssl_certificates, :kind_of => Array, :default => []
attribute :admin_bind_address, :kind_of => String, :default => "127.0.0.1"
attribute :admin_bind_port, :kind_of => Integer, :default => nil
attribute :global_options, :kind_of => Hash, :default => {}
attribute :stats_auth_user, :kind_of => String, :default => nil
attribute :stats_auth_password, :kind_of => String, :default => nil
attribute :frontends, :kind_of => Hash, :default => {}
