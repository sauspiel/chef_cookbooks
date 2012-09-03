%w(libpq5 libpq-dev).each do |pkg|
  package pkg do
    version node[:postgresql][:debversion]
    action :install
  end
end

execute "installing postgresql-client-common" do
  command "apt-get install -y -t #{node[:postgresql][:deb_release]} postgresql-client-common"
end

package "postgresql-client-#{node[:postgresql][:version]}" do
  version node[:postgresql][:debversion]
  action :install
end
