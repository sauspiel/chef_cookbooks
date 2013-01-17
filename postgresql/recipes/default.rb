apt_repository "pgdg" do
  uri "http://apt.postgresql.org/pub/repos/apt"
  distribution "#{node[:lsb][:codename]}-pgdg"
  components ["main"]
  keyserver "keys.gnupg.net"
  key "ACCC4CF8"
  action :add
end
