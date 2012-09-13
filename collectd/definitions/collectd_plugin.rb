define :collectd_python_plugin, :options => {}, :module => nil, :path => nil do
  t = nil
  begin
    t = resources(:template => "#{node[:collectd][:conf_dir]}/conf.d/python.conf")
  rescue ArgumentError,Chef::Exceptions::ResourceNotFound
    collectd_plugin "python" do
      options :paths=>[node[:collectd][:plugin_dir]], :modules=>{}
      template "python_plugin.conf.erb"
      cookbook "collectd"
    end
    retry
  end
  if not params[:path].empty?
    t.variables[:options][:paths] << params[:path]
  end
  t.variables[:options][:modules][params[:module] || params[:name]] = params[:options]
end
