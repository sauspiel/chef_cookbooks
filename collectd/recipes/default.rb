#
# Cookbook Name:: collectd
# Recipe:: default
#
# Copyright 2010, Atari, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "build-essential"

%w(collectd-core collectd).each do |pkg|
  apt_package_hold "#{pkg}" do
    version node[:collectd][:version]
    action [:install, :hold]
  end
end

service "collectd" do
  supports :restart => true, :status => true
end

directory "#{node[:collectd][:conf_dir]}/conf.d" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory "#{node[:collectd][:conf_dir]}/conf_unmanaged.d" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory "#{node[:collectd][:custom_plugins]}" do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory File.dirname("#{node[:collectd][:custom_typesdb]}") do
  owner "root"
  group "root"
  mode "755"
end

template "#{node[:collectd][:custom_types_db]}" do
  owner "root"
  group "root"
  mode 644
  source "custom_typesdb.erb"
  action :create_if_missing
end

if node[:collectd][:remove_lvm2]
  package "lvm2" do
    action :remove
    ignore_failure true
  end
end

types_dbs = Array.new
types_dbs.concat(node[:collectd][:types_db])
types_dbs << node[:collectd][:custom_types_db]

template "#{node[:collectd][:conf_dir]}/collectd.conf" do
  source "collectd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, resources(:service => "collectd")
  variables :types_dbs => types_dbs
end

service "collectd" do
  action [:enable]
end
