apt_repository "erlang_solutions" do
  uri "http://packages.erlang-solutions.com/debian"
  distribution node[:lsb][:codename]
  components ["contrib"]
  key "http://packages.erlang-solutions.com/debian/erlang_solutions.asc"
  action :add
end

template '/etc/apt/preferences.d/erlang.pref' do
  variables name: 'esl-erlang', version: node[:erlang][:version]
end

apt_package "esl-erlang" do
  version node[:erlang][:version]
  action :install
end
