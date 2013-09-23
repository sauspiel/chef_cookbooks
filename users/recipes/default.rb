gem_package "ruby-shadow"
ruby_block "require shadow library" do
  block do
    Gem.clear_paths
    require 'shadow'
  end
end

groups = search(:groups)

groups.each do |group|
  
  if node[:active_groups].include?(group[:id])

    group group[:id] do
      group_name group[:id]
      gid group[:gid]
      action [ :create, :modify, :manage ]
    end

    search(:users, "groups:#{group[:id]}").each do |user|
      users_manage_user user[:id] do
        action :create
      end
    end

  end
end

# Remove initial setup user and group.
user  "ubuntu" do
  action :remove
end

group "ubuntu" do
  action :remove
end

template "/root/.profile" do
  owner "root"
  group "root"
  mode "0600"
  source '.profile'
end

