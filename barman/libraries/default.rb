def barman_master_servers
  servers = Array.new
  node[:barman][:databases].each do |name, conf|

    master = search(:node, "postgresql_role:master AND chef_environment:#{node.chef_environment} AND postgres_databases:#{name}").first
    if master.nil?
      Chef::Log.warn("Could not find any master servers for database #{name} in #{node.chef_environment} environment")
    else
      eth = conf[:ssh_master_eth] || master[:postgresql][:interfaces].reject { |i| i == "lo" }.first
      x = Hash.new
      x[:id] = name
      x[:ip] = master[:network][:interfaces][eth][:addresses].detect { |k,v| v[:family] == 'inet' }.first

      x[:ssh_master_address] = conf[:ssh_master_address] || x[:ip]
      x[:pg_master_address] = conf[:pg_master_address] || x[:ip]
      x[:pg_master_port] = conf[:pg_master_port] || 5432

      x[:name] = master[:fqdn]

      x[:bandwidth_limit] = conf[:bandwidth_limit]

      servers << x if servers.select { |f| f[:ip] == x[:ip] }.count == 0
    end
  end
  return servers
end
