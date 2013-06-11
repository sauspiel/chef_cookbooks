def nginx_bind_address_to_s(port)
  if node[:nginx][:bind_interface].nil? || node[:nginx][:bind_interface]['all']
    return port
  else
    return "#{node[:network][:interfaces][node[:nginx][:bind_interface]][:addresses].select { |addr,data| data["family"] == "inet" }.keys[0]}:#{port}"
  end
end

def bind_address_to_s(port)
  Chef::Log.warn("\'bind_address_to_s' is deprecated. Use \'nginx_bind_address_to_s\'!")
  return nginx_bind_address_to_s(port)
end

def nginx_spdy_support?
  return `nginx -V 2>&1`.include?("--with-http_spdy_module")
end
