def nsd_ipaddress_by_dns_data_bag(domain, host)
  search(:dns, "id:#{domain.gsub(/\./,"_")}").first[:host].select { |k,v| k[host] || (!k["alias"].nil? && k["alias"].include?(host)) }.first.first[1]
end
