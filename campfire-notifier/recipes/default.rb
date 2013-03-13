include_recipe 'bundler'

remote_directory node[:campfire_notifier][:dir] do
  source "campfire-notifier"
  files_owner "root"
  files_group "root"
  files_mode 0755
  owner "root"
  group "root"
  mode 0755
  action :create
end

execute "bundle" do
  command "bundle install --path vendor/bundle"
  cwd node[:campfire_notifier][:dir]
end
