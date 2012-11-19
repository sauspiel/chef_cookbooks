user = search(:users, "id:postgres").first

directory "/var/lib/postgresql/.ssh" do
  owner "postgres"
  group "postgres"
  mode 0700
  action :create
end

if user[:ssh_private_key]
  template "/var/lib/postgresql/.ssh/id_rsa" do
    source "private_key.erb"
    action :create
    owner "postgres"
    group "postgres"
    variables :key => user[:ssh_private_key]
    mode 0600
  end
end

if user[:ssh_key]
  template "/var/lib/postgresql/.ssh/id_rsa.pub" do
    source "public_key.erb"
    action :create
    owner "postgres"
    group "postgres"
    variables :key => user[:ssh_key]
    mode 0600
  end
end

keys = Mash.new
keys[user[:id]] = user[:ssh_key]

if user[:extra_ssh_keys]
  user[:extra_ssh_keys].each do |username|
    keys[username] = search(:users, "id:#{username}").first[:ssh_key]
  end
end

template "/var/lib/postgresql/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  action :create
  owner "postgres"
  group "postgres"
  variables :keys => keys
  mode 0600
end


