def add_type(new_resource)
  unless system("grep ^#{new_resource.ds_name} #{node[:collectd][:custom_types_db]}")
    execute "adding type to #{node[:collectd][:custom_types_db]}" do
      command "echo #{new_resource.ds_name} value:#{new_resource.ds_type}:#{new_resource.min}:#{new_resource.max} >> #{node[:collectd][:custom_types_db]}"
      action :nothing
    end.run_action(:run)
  end
end

action :add do
  add_type(new_resource)
end
