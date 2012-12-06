%w(erlang-base-hipe erlang-nox).each do |pkg|
  apt_package_hold "#{pkg}" do
    default_release node[:erlang][:debian_release]
    version node[:erlang][:version]
    action [:install, :hold]
  end
end
