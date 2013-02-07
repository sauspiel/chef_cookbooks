mysql = gem_package "mysql" do
  action :nothing
end

mysql.run_action(:install)

require 'rubygems'
Gem.clear_paths
require 'mysql'
