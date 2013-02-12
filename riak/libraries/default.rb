def riak_search_nodes(cluster_name)
  return search(:node, "riak_core_cluster_name:#{cluster_name} AND chef_environment:#{node.chef_environment} AND recipes:riak\\:\\:*")
end
