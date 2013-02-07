include_recipe "percona::client"

chef_gem 'mysql' do
  action :nothing
end.run_action(:install)

