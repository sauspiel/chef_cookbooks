include_recipe "percona::default"

r = package "percona-server-client" do
  options "--force-yes"
end

r.run_action(:install)

