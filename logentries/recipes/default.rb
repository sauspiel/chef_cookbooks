package "python-simplejson"

apt_repository "logentries" do
  uri "http://rep.logentries.com"
  distribution node.lsb.codename
  components ["main"]
  key "http://rep.logentries.com/RPM-GPG-KEY-logentries"
  action :add
end

directory "/etc/le"

template "/etc/le/config" do
  not_if { File.exists?("/etc/le/config") }
  variables :key => node[:logentries][:user_key]
end

# preventing logentries-daemon from being started after installation
ruby_block "creating policy-rc.d file" do
  block do
    apt_create_policy_rc_d_file
  end
end

execute "echo Y | apt-get install --yes logentries-daemon --force-yes"

%w(logentries-daemon logentries).each do |pkg|
  package pkg do
    action :upgrade
  end
end

execute "register agent" do
  command "le register"
  not_if "grep agent-key /etc/le/config"
end

# allowing start of logentries daemon
ruby_block "deleting policy-rc.d file" do
  block do
    apt_remove_policy_rc_d_file
  end
end

service "logentries" do
  supports :restart => true
end

if node[:logentries][:logs]
  node[:logentries][:logs].each do |name, path|
    execute "follow file #{name} at #{path}" do
      command "le follow #{path} --name \"#{name}\""
      not_if "le followed #{path}"
      ignore_failure true
    end
  end
end

service "logentries" do
  action [:enable, :restart]
end



