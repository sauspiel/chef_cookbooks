include_recipe "postgresql::default"

%w(libpq5 libpq-dev postgresql-client-common).each do |pkg|
  apt_package pkg do
    action :install
    options "--force-yes"
  end
end

apt_package "postgresql-client-#{node[:postgresql][:version]}" do
  action :install
end
