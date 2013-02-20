#
# Cookbook Name:: application_ruby
# Provider:: passenger
#
# Copyright 2012, ZephirWorks
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

include Chef::Mixin::LanguageIncludeRecipe

action :before_compile do
  include_recipe "nginx"
end

action :before_deploy do

  new_resource = @new_resource

  template "#{node[:nginx][:dir]}/sites-available/#{new_resource.name}.conf" do
    source new_resource.template
    cookbook new_resource.cookbook
    variables new_resource.variables
    owner new_resource.user
    group new_resource.group
  end

  nginx_site new_resource.name do
    action [:create, :enable]
  end

end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end
