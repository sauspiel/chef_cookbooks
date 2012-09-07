package "apt-transport-https"

apt_repository "boundary" do
  uri "https://apt.boundary.com/debian/"
  distribution node['lsb']['codename']
  components ["main"]
  key "https://apt.boundary.com/APT-GPG-KEY-Boundary"
  action :add
end

cookbook_file "#{Chef::Config[:file_cache_path]}/cacert.pem" do
  source "cacert.pem"
  mode 0600
  owner "root"
  group "root"
end
