#
# Author:: Benjamin Black (<b@b3k.us>) and Sean Cribbs (<sean@basho.com>) and Seth Thomas (<sthomas@basho.com>)
# Cookbook Name:: riak
# Recipe:: package
#
# Copyright (c) 2013 Basho Technologies, Inc.
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

version_str = "#{node['riak']['package']['version']['major']}.#{node['riak']['package']['version']['minor']}"
base_uri = "#{node['riak']['package']['url']}/#{version_str}/#{version_str}.#{node['riak']['package']['version']['incremental']}/"
base_filename = "riak-#{version_str}.#{node['riak']['package']['version']['incremental']}"

case node['platform']
when "fedora", "centos", "redhat"
  node.set['riak']['config']['riak_core']['platform_lib_dir'] = "/usr/lib64/riak".to_erl_string if node['kernel']['machine'] == 'x86_64'
  machines = {"x86_64" => "x86_64", "i386" => "i386", "i686" => "i686"}
  base_uri = "#{base_uri}#{node['platform']}/#{node['platform_version'].to_i}/"
  package_file = "#{base_filename}-#{node['riak']['package']['version']['build']}.fc#{node['platform_version'].to_i}.#{node['kernel']['machine']}.rpm"
  package_uri = base_uri + package_file
  package_name = package_file.split("[-_]\d+\.").first
end

if node['riak']['package']['local_package'] 
  package_file = node['riak']['package']['local_package']

  cookbook_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    source package_file
    owner "root"
    mode 0644
    not_if(File.exists?("#{Chef::Config[:file_cache_path]}/#{package_file}") && Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/#{package_file}").hexdigest == checksum_val)
  end
else
  case node['platform']
  when "ubuntu", "debian"
    include_recipe "apt"
    
    apt_repository "basho" do
      uri "http://apt.basho.com"
      distribution node['lsb']['codename']
      components ["main"]
      key "http://apt.basho.com/gpg/basho.apt.key"
    end

    package_version_name = "#{node['riak']['package']['version']['major']}.#{node['riak']['package']['version']['minor']}.#{node['riak']['package']['version']['incremental']}"
    if node['riak']['package']['version']['minor'] >= 3
      package_version_name += "~#{node['lsb']['codename']}"
    end

    if node['riak']['package']['version']['build'] != nil
      if node['riak']['package']['version']['minor'] >= 3
        package_version_name += "#{node['riak']['package']['version']['build']}"
      else
        package_version_name += "-#{node['riak']['package']['version']['build']}"
      end
    end
    
    apt_package_hold "riak" do
      version package_version_name
      action [:install,:hold]
    end

  when "centos", "redhat"
    include_recipe "yum"

    yum_key "RPM-GPG-KEY-basho" do
      url "http://yum.basho.com/gpg/RPM-GPG-KEY-basho"
      action :add
    end

    yum_repository "basho" do
      repo_name "basho"
      description "Basho Stable Repo"
      url "http://yum.basho.com/el/#{node['platform_version'].to_i}/products/x86_64/"
      key "RPM-GPG-KEY-basho"
      action :add
    end

    package "riak" do
      action :install
    end

  when "fedora"

    remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
      source package_uri
      owner "root"
      mode 0644
      not_if(File.exists?("#{Chef::Config[:file_cache_path]}/#{package_file}") && Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/#{package_file}").hexdigest == node['riak']['package']['checksum']['local'])
    end

    package package_name do
      source "#{Chef::Config[:file_cache_path]}/#{package_file}"
      action :install
    end
  end
end
