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

  eye_app full_name do
    template 'haproxy.eye.erb'
    cookbook 'haproxy'
    variables full_name: full_name,
      short_name: name
  end
end
