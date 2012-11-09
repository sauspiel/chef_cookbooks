#
# Cookbook Name:: collectd
# Attributes:: default
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

default[:collectd][:version] = "5.1.0-3~bpo60+1"
default[:collectd][:base_dir] = "/var/lib/collectd"
default[:collectd][:conf_dir] = "/etc/collectd"
default[:collectd][:plugin_dir] = "/usr/lib/collectd"
default[:collectd][:types_db] = ["/usr/share/collectd/types.db"]
default[:collectd][:custom_plugins] = "/usr/local/collectd/plugins"
default[:collectd][:remove_lvm2] = false

default[:collectd][:interval] = 10
default[:collectd][:read_threads] = 5
default[:collectd][:name] = node[:fqdn]

default[:collectd][:plugins] = Mash.new
default[:collectd][:servers] = []
default[:collectd][:custom_typesdb] = "/usr/local/collectd/custom_types.db"
