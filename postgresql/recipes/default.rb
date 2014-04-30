components = ["main"]
components << node[:postgresql][:version] if node[:postgresql][:version].to_f < 9.3

apt_repository "pgdg" do
  uri "http://apt.postgresql.org/pub/repos/apt"
  distribution "#{node[:lsb][:codename]}-pgdg"
  components components
  key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
  action :add
end
