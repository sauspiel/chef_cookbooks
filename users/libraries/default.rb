def ssh_key(node, user)
  case user[:ssh_key]
    when String
      user[:ssh_key]
    when Hash
      ssh_key_from_hash(node, user)
  end
end

def ssh_key_from_hash(node, user)
  hash = user[:ssh_key]
  if hash[node.fqdn]
    key = hash[node.fqdn]
  elsif hash[node.chef_environment]
    key = hash[node.chef_environment]
  else
    key = hash["default"]
  end
end
