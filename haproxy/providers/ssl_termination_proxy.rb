action :add do
  run_context.include_recipe "haproxy::default"
  run_context.include_recipe "ssl_certificates"

  new_resource.ssl_certificates.each do |cert|
    ssl_certificate cert
  end

  name = "haproxy_ssl_term_#{new_resource.name}"

  template "/etc/haproxy/#{name}.conf" do
    owner node.haproxy[:user]
    group node.haproxy[:group]
    mode 0640
    source "haproxy_ssl_term.conf.erb"
    cookbook "haproxy"
    variables :config => new_resource
  end
end
