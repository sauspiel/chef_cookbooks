include_recipe "postgresql::default"

%w(libpq5 libpq-dev).each do |pkg|
  apt_package_hold pkg do
    version node[:postgresql][:debversion]
    action [:install, :hold]
    options "--force-yes"
  end
end

apt_package "postgresql-client-common" do
  default_release "squeeze-backports"
end

apt_package_hold "postgresql-client-#{node[:postgresql][:version]}" do
  version node[:postgresql][:debversion]
  default_release node[:postgresql][:deb_release]
  action [:install, :hold]
end
