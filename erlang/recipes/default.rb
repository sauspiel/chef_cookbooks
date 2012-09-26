package "erlang" do
  default_release node[:erlang][:debian_release]
  version node[:erlang][:version]
end