#
# Cookbook Name:: unbound
# Recipe:: default
#
# Copyright 2011, Joshua Timberman
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

root_group = value_for_platform(
  "freebsd" => { "default" => "wheel" },
  "default" => "root"
)

package "unbound" do
  action :upgrade
end

directory "#{node['unbound']['directory']}/conf.d" do
  mode 0755
  owner "root"
  group root_group
end

template "#{node['unbound']['directory']}/unbound.conf" do
  source "unbound.conf.erb"
  mode 0644
  owner "root"
  group root_group
  notifies :restart, "service[unbound]"
end

local_zones = Array.new
node[:dns][:domains].each do |domain|
  begin
    local_zones << data_bag_item("dns", domain.gsub(/\./, "_"))
  rescue
    local_zones << domain
  end
end

%w{ local forward stub }.each do |type|

  template "#{node['unbound']['directory']}/conf.d/#{type}-zone.conf" do
    source "#{type}-zone.conf.erb"
    mode 0644
    owner "root"
    group root_group
    variables(:local_zones => local_zones, :default_ttl => node['unbound']['local_zones']['default_ttl'])
    notifies :restart, "service[unbound]"
  end

end

# Not yet supported.
# include_recipe "unbound::remote_control" if node['unbound']['remote_control']['enable']

service "unbound" do
  supports value_for_platform(
    ["redhat", "centos", "fedora"] => { "default" => ["status", "restart", "reload"]},
    "freebsd" => {"default" => ["status", "restart", "reload"]},
    ["debian", "ubuntu"] => {"default" => ["restart"]},
    "default" => "restart"
  )
  action [:enable, :start]
end
