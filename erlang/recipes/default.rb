%w(erlang-base-hipe erlang-nox).each do |pkg|
  apt_package "#{pkg}" do
    version node[:erlang][:version]
    action :install
  end
end
