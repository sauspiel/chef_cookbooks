action :remove do
  user = search(:users, "id:#{new_resource.name}").first

  user user[:id] do
    action :remove
  end
end

action :create do
  user = search(:users, "id:#{new_resource.name}").first
  groups = search(:groups)
  home_dir = user[:home_dir] || "/home/#{user[:id]}"

  user_group = user[:groups].first

  # make sure users main group exists before creating the user and assigning a group to it
  group user_group do
    group_name user_group.to_s
    gid groups.find { |grp| grp[:id] == user_group }[:gid]
    action [ :create, :modify, :manage ]
  end

  # check if parent directory exists

  if home_dir != "/dev/null"
    parent_dir = Pathname.new(home_dir).parent
    directory parent_dir.to_s do
      owner 'root'
      group 'root'
      mode 0755
      not_if { ::File.exists?(parent_dir) }
      action :create
    end
  end


  user user[:id] do
    comment user[:full_name]
    uid user[:uid]
    gid groups.find { |grp| grp[:id] == user[:groups].first }[:gid]
    home home_dir
    shell user[:shell] || "/bin/bash"
    password user[:password]
    if home_dir == "/dev/null"
      supports :manage_home => false
    else
      supports :manage_home => true
    end
    action [:create, :manage]
  end

  user[:groups].each do |g|
    group g do
      group_name g.to_s
      gid groups.find { |grp| grp[:id] == g }[:gid]
      members user[:id]
      append true
      not_if { g == user[:groups].first }
      action [:create, :modify, :manage]
    end
  end

  if (!node[:users][:manage_files] && !user[:local_files])
    Chef::Log.info "Not managing files for #{user[:id]} because home directory does not exist or this is not a management host."
  else
    directory "#{home_dir}" do
      owner user[:id]
      group user[:groups].first.to_s
      mode 0700
      recursive true
    end

    directory "#{home_dir}/.ssh" do
      action :create
      owner user[:id]
      group user[:groups].first.to_s
      mode 0700
    end

    keys = Mash.new
    keys[user[:id]] = user[:ssh_key]

    if user[:ssh_key_groups]
      user[:ssh_key_groups].each do |group|
        users = search(:users, "groups:#{group}")
        users.each do |key_user|
          keys[key_user[:id]] = key_user[:ssh_key]
        end
      end
    end

    if user[:extra_ssh_keys]
      user[:extra_ssh_keys].each do |username|
        keys[username] = search(:users, "id:#{username}").first[:ssh_key]
      end
    end

    if user[:ssh_private_key]
      template "#{home_dir}/.ssh/id_rsa" do
        cookbook new_resource.cookbook 
        source "private_key.erb"
        action :create
        owner user[:id]
        group user[:groups].first.to_s
        variables(:key => user[:ssh_private_key])
        mode 0600
      end
    end
    
    template "#{home_dir}/.ssh/authorized_keys" do
      cookbook new_resource.cookbook
      source "authorized_keys.erb"
      action :create
      owner user[:id]
      group user[:groups].first.to_s
      variables(:keys => keys)
      mode 0600
      not_if { user[:preserve_keys] }
    end
  end
end
