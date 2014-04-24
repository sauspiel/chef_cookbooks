include_recipe "redis"

if node[:redis][:instances]  

  node[:redis][:instances].each do |name, config|  

    default_config = {
      "name" => "redis_#{name}",
      "log_path" => "#{node[:redis][:root_path]}/#{name}/redis.log",
      "pid_path" => "#{node[:redis][:root_path]}/#{name}/redis.pid",
      "data_directory" => "#{node[:redis][:root_path]}/#{name}/data",
      "config_path" => "#{node[:redis][:root_path]}/#{name}/redis.conf",
      "root" => "#{node[:redis][:root_path]}/#{name}",
      "owner" => "redis",
      "group" => "redis"
    }
    
    merged_config = node[:redis].to_hash.merge(default_config).merge(config)

    directory merged_config["root"] do
      owner merged_config["owner"]
      group merged_config["group"]
      mode 0750
      recursive true
    end

    directory merged_config["data_directory"] do
      owner merged_config["owner"]
      group merged_config["group"]
      mode 0750
      recursive true
    end
    
    template merged_config["config_path"] do
      owner merged_config["owner"]
      group merged_config["group"]
      variables merged_config
      mode 0644      
    end

    # for some reason logfile will be created with root ownership
    file merged_config["log_path"] do
      owner merged_config["owner"]
      group merged_config["group"]
      mode 0750
      action :create_if_missing
    end

    eye_app "redis_#{name}" do
      template 'redis.eye.erb'
      cookbook 'redis'
      variables merged_config
    end
  end
end
