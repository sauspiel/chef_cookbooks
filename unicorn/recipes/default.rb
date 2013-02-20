include_recipe "ruby::gc_wrapper"

gem_package "unicorn" do
  version node[:unicorn][:version]
end

directory node[:unicorn][:config_path] do
  mode 0755
end

directory node[:unicorn][:rundir] do
  mode 0755
  owner node[:unicorn][:user]
  group node[:unicorn][:user]
end

cookbook_file "/usr/local/bin/unicornctl" do
  mode 0755
end
