additional_components = []
%w(production beta staging development).each do |c| 
  additional_components << c
  break if node.chef_environment.match(/#{c}/)
end

additional_components[0] = 'main'

apt_repository "sauspiel" do
  uri "http://apt-sauspiel.s3.amazonaws.com/debian"
  distribution "#{node.lsb.codename}-sauspiel"
  components additional_components
  key "https://apt-sauspiel.s3.amazonaws.com/apt@sauspiel.de.gpg.key"
  action :nothing
end.run_action(:add)

package 'ruby' do
  package_name node[:ruby][:package_name]
  version node[:ruby][:version]
  action :nothing
end.run_action(:install)

ohai "reload_ruby" do
  plugin 'languages/ruby'
  action :nothing
end.run_action(:reload)
