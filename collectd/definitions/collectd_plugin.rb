define :collectd_python_plugin, :options => {}, :module => nil, :path => nil do
  newoptions = {}
  newoptions[:paths] = [node[:collectd][:plugin_dir]]
  newoptions[:modules] = {}
  if not params[:path].empty?
    newoptions[:paths] << params[:path]
  end
  newoptions[:modules][params[:module] || params[:name]] = params[:options]

  collectd_plugin "python" do
    options newoptions 
    template "python_plugin.conf.erb"
    cookbook "collectd"
    not_if { File.exists?("#{node[:collectd][:conf_dir]}/conf.d/python.conf") }
  end
end
