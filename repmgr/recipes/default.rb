include_recipe "bluepill"

package "repmgr"

template "#{node[:repmgr][:config]}" do
  source "repmgr.conf.erb"
end
