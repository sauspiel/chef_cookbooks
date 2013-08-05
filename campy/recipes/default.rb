chef_gem "campy" do
  version node[:campy][:version]
  action :nothing
end.run_action(:install)

gem_package "campy" do
  version node[:campy][:version]
  action :nothing
end.run_action(:install)
