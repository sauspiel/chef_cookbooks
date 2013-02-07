#
# Cookbook Name:: percona
# Recipe:: default
#

# include Opscode LWRP apt cookbook
include_recipe 'apt'

# configure apt repository
apt_repository "percona" do
  uri "http://repo.percona.com/apt"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver node["percona"]["keyserver"]
  key "1C4CBDCDCD2EFD2A"
  action :add
end

template "/etc/apt/preferences.d/percona" do
  source "apt-preferences.erb"
  owner "root"
  group "root"
  mode 0644
end


# install dependent package
%w(libmysqlclient16 libmysqlclient16-dev libmysqlclient18 libmysqlclient-dev libmysqlclient18-dev).each do |pkg|
  package pkg do
    action :install
    options "--force-yes"
  end
end
