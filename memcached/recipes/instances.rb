include_recipe "memcached"

service "memcached" do
  action [:stop, :disable]
end

if node[:memcached][:instances]
  node[:memcached][:instances].each do |name, instance|
    full_name = "memcached_#{name}"
    memcached_config = { "name" => full_name,
                         "max_memory" => node[:memcached][:max_memory],
                         "port" => node[:memcached][:port], "user" => node[:memcached][:user],
                         "max_connections" => node[:memcached][:max_connections],
                         "pid_path" => "/var/run/memcached_#{name}.pid",
                         "user" => "root",
                         "group" => "root",
                         "slab_page_size" => node[:memcached][:slab_page_size],
                         "bind_address" => node[:memcached][:bind_address]}.merge(instance)

    eye_app full_name do
      template 'memcached.eye.erb'
      cookbook 'memcached'
      variables memcached_config
    end
  end
end
