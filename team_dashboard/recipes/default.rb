include_recipe "team_dashboard::database"

%w(libxml2 libxml2-dev libxslt1.1 libxslt1-dev).each do |pkg|
  package pkg
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

  before_migrate do
    bash "modifying_gemfile" do
      cwd release_path
      code <<-EOF
      echo 'gem "unicorn", "~> #{node[:unicorn][:version]}"' >> Gemfile
      EOF
      not_if "grep -q unicorn Gemfile"
    end
  end

  rails do
    bundler true
    bundler_deployment false
    database do
      database "team_dashboard_#{env}"
      username "dashboard_web"
      password db_password
      adapter "mysql2"
      host "localhost"
    end
  end

  unicorn_bp do
    worker_processes 2
    preload_app true
    worker_timeout 300
    environment_vars :GRAPHITE_URL => node[:team_dashboard][:graphite_url]
  end

  nginx do
    cookbook "team_dashboard"
    template "nginx.conf.erb"
    variables :app_name => "team_dashboard", :domain => app["environments"][env]["domain"]
  end
end
