define :ssl_certificate do

  directory node[:ssl_certificates][:path] do
    mode 0750
    owner node[:ssl_certificates][:owner]
    group node[:ssl_certificates][:group]
    action :create
  end
  
  name = ssl_certificate_as_wildcard(params[:name])

  # gsub is required since databags can't contain dashes
  cert = Chef::EncryptedDataBagItem.load(:certificates, name.gsub(".", "_"))
  
  template "#{node[:ssl_certificates][:path]}/#{name}.crt" do
    source "cert.erb"
    mode "0640"
    cookbook "ssl_certificates"
    owner node[:ssl_certificates][:owner]
    group node[:ssl_certificates][:group]
    variables :cert => cert["cert"]
  end

  template "#{node[:ssl_certificates][:path]}/#{name}.key" do
    source "cert.erb"
    mode "0640"
    cookbook "ssl_certificates"
    owner node[:ssl_certificates][:owner]
    group node[:ssl_certificates][:group]
    variables :cert => cert["key"]
  end

  template "#{node[:ssl_certificates][:path]}/#{name}_combined.crt" do
    source "cert.erb"
    mode "0640"
    cookbook "ssl_certificates"
    owner node[:ssl_certificates][:owner]
    group node[:ssl_certificates][:group]
    extra = cert["intermediate"] || ""
    variables :cert => cert["cert"], :extra => extra
  end

  if cert["intermediate"]
    template "#{node[:ssl_certificates][:path]}/#{name}_intermediate.crt" do
      source "cert.erb"
      mode "0640"
      cookbook "ssl_certificates"
      owner node[:ssl_certificates][:owner]
      group node[:ssl_certificates][:group]
      variables :cert => cert["intermediate"]
    end
  end

  template "#{node[:ssl_certificates][:path]}/#{name}_all_in_one.crt" do
    source "cert.erb"
    mode "0640"
    cookbook "ssl_certificates"
    owner node[:ssl_certificates][:owner]
    group node[:ssl_certificates][:group]
    variables :cert => "#{cert["key"]}\n#{cert["cert"]}\n#{(cert["intermediate"] || "")}"
  end
end
