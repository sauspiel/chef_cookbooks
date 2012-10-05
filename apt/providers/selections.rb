def deny_upgrade(pkg)
  if system("dpkg --get-selections | grep #{pkg}")
    execute "denying upgrade for #{pkg}" do
      command "echo \"#{pkg} hold\" | dpkg --set-selections"
      action :nothing
    end.run_action(:run)
  end
end

def allow_upgrade(pkg)
  if system("dpkg --get-selections | grep #{pkg}")
    execute "allowing upgrade of #{pkg}" do
      command "echo \"#{pkg} install\" | dpkg --set-selections"
      action :nothing
    end.run_action(:run)
  end
end

action :deny_upgrade do
  deny_upgrade(new_resource.pkg)
end

action :allow_upgrade do
  allow_upgrade(new_resource.pkg)
end
