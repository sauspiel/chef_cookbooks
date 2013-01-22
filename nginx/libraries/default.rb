def bind_address_to_s(port)
  if node[:nginx][:bind_interface].nil? || node[:nginx][:bind_interface]['all']
    return port
  else
    return "#{node[:network][:interfaces][node[:nginx][:bind_interface]][:addresses].select { |address, data| data["family"] == "inet" }[0][0]}:#{port}"
  end
end

def nginx_spdy_support?
  return `nginx -V 2>&1`.include?("--with-http_spdy_module")
end
