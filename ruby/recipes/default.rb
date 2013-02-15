package "libffi5"
package "libyaml-0-2"

tmp = node[:tmp] ? node[:tmp] : "/tmp"
rubypkg = "ruby-#{node.ruby.version}.deb"
debpath = "#{tmp}/#{rubypkg}"

remote_file "#{debpath}" do
  source "#{node[:package_url]}/#{rubypkg}"
  not_if { File.exists?("#{debpath}") }
end

version = node.ruby.version.gsub("_amd64","")
dpkg_package "ruby" do
  version version
  source "#{debpath}"
  not_if { "dpkg-query -W ruby-#{version}" }
  only_if { File.exists?("#{debpath}") }
end
