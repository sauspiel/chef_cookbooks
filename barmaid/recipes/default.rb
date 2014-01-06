include_recipe "barman"
include_recipe "nginx"

env = node.chef_environment
env = 'development' if env == '_default'

node.default[:unicorn][:user] = "barman"
node.default[:unicorn][:group] = "barman"

app = search(:apps, "id:barmaid").first

htpasswd = nil
if app["environments"][env]["htpasswd"]
  user = app["environments"][env]["htpasswd"]
  pw = Chef::EncryptedDataBagItem.load("passwords", "http")[user].crypt("salt")
  htpasswd = {
    :user => user,
    :passwd => pw
  }

  template "#{node[:nginx][:dir]}/htpasswd.d/barmaid.htpasswd" do
    source "htpasswd.erb"
    variables :htpasswd => htpasswd
    owner node[:nginx][:user]
    group node[:nginx][:group]
    mode 0600
  end
  
end

service "barmaid" do
  supports [:start, :stop, :restart]
end

service "barmaid-resque" do
  supports [:start, :stop, :restart]
end

%w{config log tmp jobs scripts}.each do |dir|
  directory "#{node[:barmaid][:path]}/shared/#{dir}" do
    owner "barman"
    group "barman"
    mode 0755
    recursive true
    action :create
  end
end

template "#{node[:bluepill][:conf_dir]}/barmaid-resque.pill" do
  mode 0644
  source "bluepill-resque.pill.erb"
  variables :name => "barmaid-resque",
    :log => "log/resque.log",
    :root => "#{node[:barmaid][:path]}/current",
    :env => env,
    :pid_file => "tmp/pids/resque.pid",
    :gid => "barman",
    :uid => "barman"
end

application "barmaid" do
  path node[:barmaid][:path]
  repository node[:barmaid][:repository]
  scm_provider Chef::Provider::Git
  owner "barman"
  group "barman"
  revision node[:barmaid][:repository_revision]
  environment_name env
  symlinks "config/barmaid.yml" => "config/barmaid.yml",
    "config/resque.yml" => "config/resque.yml",
    "log" => "log",
    "tmp" => "tmp",
    "scripts" => "scripts"
  action :deploy

  before_symlink do
    %w(barmaid resque).each do |conf|
      file = "#{node[:barmaid][:path]}/shared/config/#{conf}.yml"
      template file do
        owner "barman"
        group "barman"
        source "#{conf}.yml.erb"
        action :create_if_missing
      end
    end
  end

  after_restart do
    bluepill_service "barmaid-resque" do
      action [:enable, :load, :restart]
      only_if { ::File.exist?("/etc/init.d/barmaid-resque") }
    end
  end

  rails do
    bundler true
    bundle_command "/usr/local/bin/bundle"
  end

  unicorn_bp do
    worker_processes 2
    preload_app false
    user "barman"
    group "barman"
    cookbook "barmaid"
  end

  nginx do
    user "barman"
    group "barman"
    cookbook "barmaid"
    template "nginx.conf.erb"
    variables :app_name => "barmaid",
      :domain => node[:fqdn],
      :htpasswd => htpasswd
  end
end
