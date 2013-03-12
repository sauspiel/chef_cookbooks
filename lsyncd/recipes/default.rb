package "lsyncd" do
  version node[:lsyncd][:version]
end

directory node[:lsyncd][:conf_dir]
directory node[:lsyncd][:log_dir]
directory node[:lsyncd][:run_dir]
