action :create do
  if new_resource.run_levels 
    new_resource.run_levels.each do |run_level| 
      policy_path = "/etc/policy-rc.d/#{new_resource.name}/#{run_level}"
      ::FileUtils.mkdir_p(policy_path)
      if new_resource.default_policy 
          ::File.open(policy_path + "/default-policy", 'w') {|f| f.write(new_resource.status)}
      else
        new_resource.init_actions.each  do |action|
          ::File.open(policy_path + "/" + action, 'w') {|f| f.write(new_resource.status)}
        end
      end
    end 
  else
    policy_path = "/etc/policy-rc.d/#{new_resource.name}"
    ::FileUtils.mkdir_p(policy_path)
    if new_resource.default_policy
      ::File.open(policy_path + "/default-policy", 'w') {|f| f.write(new_resource.status)}
    else
      new_resource.init_actions.each do |action|
        File.open(policy_path + "/" + action, 'w') {|f| f.write(@new_resource.status)}
      end
    end 
  end   
end

action :delete do
  if new_resource.run_levels 
    new_resource.run_levels.each do |run_level| 
      policy_path = "/etc/policy-rc.d/#{new_resource.name}/#{run_level}"
      if new_resource.default_policy 
        if ::File.exists?(policy_path + "/default-policy")
          ::File.delete(policy_path + "/default-policy")
        end
      else
        new_resource.init_actions.each  do |action|
          if ::File.exists?(policy_path + "/" + action)
            ::File.delete(policy_path + "/" + action)
          end
        end
      end
    end 
  else
    policy_path = "/etc/policy-rc.d/#{new_resource.name}"
    if new_resource.default_policy
      if ::File.exists?(policy_path + "/default-policy")
        ::File.delete(policy_path + "/default-policy")
      end
    else
      new_resource.init_actions.each do |action|
        if ::File.exists?(policy_path + "/" + action)
          ::File.delete(policy_path + "/" + action)
        end
      end
    end 
  end   
end
