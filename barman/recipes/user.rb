user = search(:users, "id:barman").first

home = node[:barman][:home]
directory "#{home}/.ssh" do
  owner "barman"
  group "barman"
  mode 0700
  action :create
end

if user[:ssh_private_key]
  template "#{home}/.ssh/id_rsa" do
    source "private_key.erb"
    action :create
    owner "barman"
    group "barman"
    variables :key => user[:ssh_private_key]
    mode 0600
  end
end

if user[:ssh_key]
  template "#{home}/.ssh/id_rsa.pub" do
    source "public_key.erb"
    action :create
    owner "barman"
    group "barman"
    variables :key => user[:ssh_key]
    mode 0600
  end
end

keys = Mash.new

if user[:extra_ssh_keys]
  user[:extra_ssh_keys].each do |username|
    keys[username] = search(:users, "id:#{username}").first[:ssh_key]
  end
end

template "#{home}/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  action :create
  owner "barman"
  group "barman"
  variables :keys => keys
  mode 0600
end


