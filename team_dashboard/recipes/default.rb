include_recipe "team_dashboard::database"

%w(libxml2 libxml2-dev libxslt1.1 libxslt1-dev).each do |pkg|
  package pkg
end

bash "modifying_gemfile" do
  cwd node[:team_dashboard][:path]
  user user
  code <<-EOF
  echo 'gem "unicorn", "~> 4.0.1"' >> Gemfile
  EOF
  not_if "grep -q unicorn Gemfile"
  action :nothing
end

db_password = Chef::EncryptedDataBagItem.load('passwords', 'mysql')["dashboard_web"]
app = search(:apps, "id:team_dashboard").first
env = node.chef_environment
env = 'development' if env == '_default'

application "team_dashboard" do
  path node[:team_dashboard][:path]
  repository "https://github.com/fdietz/team_dashboard.git"
  scm_provider Chef::Provider::Git
  owner "deploy"
  group "deploy"
  revision "master"
  environment_name env
  enable_submodules true
  migrate true
  action :force_deploy

  rails do
    bundler true
    database do
      database "team_dashboard_#{env}"
      username "dashboard_web"
      password db_password
      adapter "mysql2"
      host "localhost"
    end
  end
end
