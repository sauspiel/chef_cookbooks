include_recipe "memcached"

service "memcached" do
  action :enable
  supports :restart => true, :reload => true
end

template node[:memcached][:conf_path] do
  source "memcached.conf.erb"  
  notifies :restart, resources(:service => "memcached")
  variables(:max_memory => node[:memcached][:max_memory],
            :port => node[:memcached][:port],
            :user => node[:memcached][:user],
            :max_connections => node[:memcached][:max_connections],
            :log_path => node[:memcached][:log_path],
            :bind_address => node[:memcached][:bind_address],
            :slab_page_size => node[:memcached][:slab_page_size]
           )
end

service "memcached" do
  action :start
end
