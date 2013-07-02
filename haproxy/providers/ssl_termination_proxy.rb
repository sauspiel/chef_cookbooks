action :add do
  run_context.include_recipe "haproxy::default"
  run_context.include_recipe "ssl_certificates"
  run_context.include_recipe "bluepill"

  ssl_certificate new_resource.ssl_certificate_id

  name = "haproxy_ssl_term_#{new_resource.name}"

  template "/etc/haproxy/#{name}.conf" do
    owner node.haproxy[:user]
    group node.haproxy[:group]
    mode 0640
    source "haproxy_ssl_term.conf.erb"
    cookbook "haproxy"
    variables :config => new_resource,
      :ssl_certificate => "#{ssl_certificate_as_wildcard(new_resource.ssl_certificate_id)}_all_in_one.crt"
  end

  template "#{node[:bluepill][:conf_dir]}/#{name}.pill" do
    variables :full_name => name, :short_name => name
    cookbook "haproxy"
    source "bluepill.conf.erb"
  end

  bluepill_service name do
    action [:enable, :load, :start]
  end
end
