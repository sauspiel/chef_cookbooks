apt_repository "erlang_solutions" do
  uri "http://binaries.erlang-solutions.com/debian"
  distribution node[:lsb][:codename]
  components ["contrib"]
  key "http://binaries.erlang-solutions.com/debian/erlang_solutions.asc"
  action :add
end

apt_package_hold "esl-erlang" do
  version node[:erlang][:version]
  action [:install, :hold]
end
