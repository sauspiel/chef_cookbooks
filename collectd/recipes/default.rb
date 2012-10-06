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
  package "#{pkg}" do
    version node[:collectd][:version]
    action :install
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

template "#{node[:collectd][:custom_typesdb]}" do
  owner "root"
  group "root"
  mode 644
  source "custom_typesdb.erb"
  action :create_if_missing
end

package "lvm2" do
  action :remove
  ignore_failure true
end

node[:collectd][:types_db] << node[:collectd][:custom_typesdb]

template "#{node[:collectd][:conf_dir]}/collectd.conf" do
  source "collectd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, resources(:service => "collectd")
end

service "collectd" do
  action [:enable]
end
