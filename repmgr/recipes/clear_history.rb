include_recipe "bluepill"

delete_or_create = :create
if node[:postgresql][:role].nil? || node[:postgresql][:role]["slave"]
  delete_or_create = :delete
end

cron "clear_repmgr_history" do
  minute "0"
  hour "5"
  command "/usr/bin/repmgr cluster cleanup -k 1 -f #{node[:repmgr][:config]}"
  user "root"
  mailto "root@localhost"
  path "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin"
  action delete_or_create
end
