include_recipe "bluepill"

package "repmgr"

template "#{node[:repmgr][:config]}" do
  source "repmgr.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

include_recipe "repmgr::clear_history"
