%w(erlang-base-hipe erlang-nox).each do |pkg|
  apt_selections "#{pkg}" do
    action :allow_upgrade
  end
end

%w(erlang-base-hipe erlang-nox).each do |pkg|
  apt_package "#{pkg}" do
    default_release node[:erlang][:debian_release]
    version node[:erlang][:version]
  end
end

%w(erlang-base-hipe erlang-nox).each do |pkg|
  apt_selections "#{pkg}" do
    action :deny_upgrade
  end
end
