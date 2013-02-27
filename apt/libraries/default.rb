def apt_remove_policy_rc_d_file
  file = "/usr/sbin/policy-rc.d"
  Chef::Log.info("Deleting #{file}")
  `rm #{file}`
end

def apt_create_policy_rc_d_file
  file = "/usr/sbin/policy-rc.d"
  Chef::Log.info("Creating #{file}")
  ::File.open(file, "w") do |f| 
    f.puts "#!/bin/sh"
    f.puts "exit 101"
  end 
  `chmod 755 #{file}`
end

