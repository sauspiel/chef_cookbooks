include_recipe "barman"

env = node.chef_environment
env = 'development' if env == '_default'

node.default[:unicorn][:user] = "barman"
node.default[:unicorn][:group] = "barman"

application "barmaid" do
  path node[:barmaid][:path]
  repository node[:barmaid][:repository]
  scm_provider Chef::Provider::Git
  owner "barman"
  group "barman"
  revision node[:barmaid][:repository_revision]
  environment_name env
  enable_submodules true
  action :force_deploy

  rails do
    bundler true
    bundler_deployment false
  end

  before_restart do
    %w(barmaid resque).each do |conf|
      template "#{release_path}/config/#{conf}.yml" do
        owner "barman"
        group "barman"
        source "#{conf}.yml.erb"
      end
    end
  end

  unicorn_bp do
    worker_processes 2
    preload_app false
    user "barman"
    group "barman"
    cookbook "barmaid"
  end
end
