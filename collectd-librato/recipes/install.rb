include_recipe "collectd"

# Install plugin
collectd_python_plugin "collectd-librato" do
  path "/opt/collectd-librato-#{node[:collectd_librato][:version]}/lib"
  options({
            "APIToken" => node[:collectd_librato][:api_token],
            "Email" => node[:collectd_librato][:email]
          })
end
