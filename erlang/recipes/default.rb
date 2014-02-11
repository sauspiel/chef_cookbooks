apt_repository "erlang_solutions" do
  uri "http://packages.erlang-solutions.com/debian"
  distribution node[:lsb][:codename]
  components ["contrib"]
  key "http://packages.erlang-solutions.com/debian/erlang_solutions.asc"
  action :add
end

template '/etc/apt/preferences.d/erlang.pref' do
  variables packages: ['esl-erlang', 'erlang-*'], version: node[:erlang][:version]
end

