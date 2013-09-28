package "ssl-cert"

directory node[:ssl_certificates][:path] do
  mode 0750
  owner node[:ssl_certificates][:owner]
  group node[:ssl_certificates][:group]
  action :create
end
