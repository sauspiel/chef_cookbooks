package "libffi5"
package "libyaml-0-2"

tmp = node[:tmp] ? node[:tmp] : "/tmp"
rubypkg = "ruby-#{node.ruby.version}.deb"
debpath = "#{tmp}/#{rubypkg}"

dpkg_package "ruby" do
  version node.ruby.version.gsub("_amd64","")
  source "#{debpath}"
  action :nothing
end

remote_file "#{debpath}" do
  source "#{node[:package_url]}/#{rubypkg}"
  not_if { File.exists?("#{debpath}") }
  action :create
  notifies :install, resource(:dpkg_package, "ruby"), :immediately
end


