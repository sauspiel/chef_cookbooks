include_recipe 'haproxy'

if node[:haproxy][:instances]
  node[:haproxy][:instances].each do |name, config|
    
    full_name = "haproxy_#{name}"
  
    template "/etc/haproxy/#{name}.cfg" do
      source "haproxy.cfg.erb"
      variables(:name => name, :config => config)
      owner node[:haproxy][:user]
      group node[:haproxy][:group]
      mode 0640
    end
  
    eye_app full_name do
      template 'haproxy.eye.erb'
      cookbook 'haproxy'
      variables full_name: full_name,
        short_name: name
    end
  end
end
