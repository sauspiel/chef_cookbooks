components = ["main"]
components << node[:postgresql][:version] if node[:postgresql][:version].to_f < 9.3

apt_repository "pgdg" do
  uri "http://apt.postgresql.org/pub/repos/apt"
  distribution "#{node[:lsb][:codename]}-pgdg"
  components components
  key "http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"
  action :add
end
