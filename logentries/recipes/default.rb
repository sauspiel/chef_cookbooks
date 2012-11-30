package "python-simplejson"

apt_repository "logentries" do
  uri "http://rep.logentries.com"
  distribution "squeeze"
  components ["main"]
  keyserver "pgp.mit.edu"
  key "C43C79AD"
  action :add
end

directory "/etc/le"

template "/etc/le/config" do
  not_if { File.exists?("/etc/le/config") }
end

execute "echo Y | apt-get install --yes logentries-daemon"

%w(logentries-daemon logentries).each do |pkg|
  package pkg do
    action :upgrade
  end
end

execute "register agent" do
  command "le register"
  not_if "grep agent-key /etc/le/config"
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



