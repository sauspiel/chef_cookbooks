#
# Cookbook Name:: policy-rc-d
# Recipe:: default
#
# Copyright 2012, Wikia Inc.
#
# All rights reserved - Do Not Redistribute
#

directory "/etc/policy-rc.d" do
  owner "root"
  group "root"
  mode  "0755" 
  action "create"
end

template "/usr/sbin/policy-rc.d" do
  mode "0755"
  owner "root"
  group "root"
  source "policy-rc.d.erb"
end

