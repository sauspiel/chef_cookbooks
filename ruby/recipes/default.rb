remote_file "/tmp/#{node.ruby.version}.deb" do
  source "#{node[:package_url]}/#{node.ruby.version}.deb"
  not_if { File.exists?("/tmp/#{node.ruby.version}.deb") }
end

dpkg_package "ruby" do
  version node.ruby.version
  source "/tmp/#{node.ruby.version}.deb"
  only_if { File.exists?("/tmp/#{node.ruby.version}.deb") }
end