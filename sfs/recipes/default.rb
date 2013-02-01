gem_package "choice"

filename = node[:sfs][:url].match(/.+\/(.+\.zip)/)[1]
tmpfile = "#{node[:sfs][:tmpdir]}/#{filename}"

firstrun = File.exists?(tmpfile)

remote_file tmpfile do
  source node[:sfs][:url]
  mode 0644
  action :create_if_missing
end

execute "unzipping zip file" do
  command "unzip -n #{tmpfile}"
  creates "#{tmpfile.gsub(".zip",".txt")}"
  cwd node[:sfs][:tmpdir]
end

outfile = "#{node[:nginx][:conf_dir]}/sfs.deny.conf"
cmd = as_nginx_deny_cmd(tmpfile.gsub(".zip", ".txt"), outfile)
Chef::Log.info("Executing #{cmd}")
execute "creating nginx conf file" do
  command cmd
  creates outfile
  not_if { File.exists?(outfile) }
end

cookbook_file "/usr/local/bin/fetch_sfs_list.rb" do
  source "fetch_sfs_list.rb"
  owner "root"
  group "root"
  mode 0755
end

cron "sfs_deny_list" do
  hour "1"
  minute "0"
  command "/usr/local/bin/fetch_sfs_list.rb >/dev/null && /etc/init.d/nginx restart >/dev/null"
  path "/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin"
end

