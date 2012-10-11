%w(libpq5 libpq-dev).each do |pkg|
  package pkg do
    version node[:postgresql][:debversion]
    action :install
  end
end

apt_package "postgresql-client-common" do
  default_release "squeeze-backports"
end

apt_package "postgresql-client-#{node[:postgresql][:version]}" do
  version node[:postgresql][:debversion]
  default_release node[:postgresql][:deb_release]
end
