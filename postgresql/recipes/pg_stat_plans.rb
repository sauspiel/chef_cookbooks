if node[:postgresql][:shared_preload_libraries].include?("pg_stat_plans")
  package "postgresql-#{node[:postgresql][:version]}-pgstatplans"
end
