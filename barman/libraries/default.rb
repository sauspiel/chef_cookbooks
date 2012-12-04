def barman_master_servers
  servers = Array.new
  node[:barman][:databases].each do |name, conf|

    master = search(:node, "postgresql_role:master AND postgres_databases_#{name}_env:production").first
    eth = conf[:ssh_master_eth] || master[:postgresql][:interfaces].reject { |i| i == "lo" }.first
    x = Hash.new
    x[:id] = name
    x[:ip] = master[:network][:interfaces][eth][:addresses].select { |address, data| data[:family] == "inet"}[0][0]

    x[:ssh_master_address] = conf[:ssh_master_address] || x[:ip]
    x[:pg_master_address] = conf[:pg_master_address] || x[:ip]
    x[:pg_master_port] = conf[:pg_master_port] || 5432

    x[:name] = master[:fqdn]

    servers << x if servers.select { |f| f[:ip] == x[:ip] }.count == 0
  end
  return servers
end
