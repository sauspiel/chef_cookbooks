include_recipe "barman"
include_recipe "nginx"

node.default[:unicorn][:user] = 'barman'
node.default[:unicorn][:group] = 'barman'

include_recipe "unicorn"

app = search(:apps, "id:barmaid").first

env = node.chef_environment

directory node[:barmaid][:path] do
  owner 'barman'
  group 'barman'
  action :create
end

base_dir = node[:barmaid][:path]
work_dir = "#{base_dir}/current"
shared_dir = "#{base_dir}/shared"

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

%w(config log tmp jobs scripts vendor/bundle unicorn).each do |dir|
  directory "#{shared_dir}/#{dir}" do
    owner "barman"
    group "barman"
    mode 0755
    recursive true
    action :create
  end
end

%w(barmaid resque).each do |conf|
  file = "#{shared_dir}/config/#{conf}.yml"
  template file do
    owner 'barman'
    group 'barman'
    source "#{conf}.yml.erb"
    action :create_if_missing
  end
end

execute "bundle_barmaid" do
  command "/usr/local/bin/bundle install --path #{shared_dir}/vendor/bundle"
  cwd work_dir
  user 'barman'
  action :nothing
end

git work_dir do
  repository node[:barmaid][:repository]
  reference node[:barmaid][:repository_revision]
  user 'barman'
  group 'barman'
  action :sync
  notifies :run, resources(:execute => "bundle_barmaid"), :immediately
end

%w(log tmp jobs scripts).each do |dir|
  link "#{work_dir}/#{dir}" do
    to "#{shared_dir}/#{dir}"
  end
end

%w(barmaid.yml resque.yml).each do |conf|
  link "#{work_dir}/config/#{conf}" do
    to "#{shared_dir}/config/#{conf}"
  end
end

unicorn_pid = "#{shared_dir}/unicorn/unicorn.pid"
unicorn_socket = "#{shared_dir}/unicorn/unicorn.sock"

template "#{node[:unicorn][:config_path]}/barmaid.conf.rb" do
  mode 0644
  cookbook 'barmaid'
  source 'unicorn.conf.erb'
  variables pid: unicorn_pid,
    working_dir: work_dir,
    env: env,
    worker_count: 2,
    socket: unicorn_socket,
    log_dir: "#{shared_dir}/log"
end

eye_app 'barmaid' do
  user_srv true
  user_srv_uid 'barman'
  user_srv_gid 'barman'
  template 'barmaid.eye.erb'
  cookbook 'barmaid'
  variables working_dir: work_dir,
    environment_vars: { "RACK_ENV" => env },
    pid: unicorn_pid,
    unicorn_cmd: "/usr/bin/env RACK_ENV=#{env} /usr/local/bin/bundle exec unicorn -Dc #{node[:unicorn][:config_path]}/barmaid.conf.rb -E #{env}",
    resque_pid: "#{shared_dir}/tmp/resque.pid",
    resque_cmd: "/usr/bin/env RACK_ENV=#{env} bundle exec rake resque:work"
end

eye_service 'barmaid' do
  action :nothing
  subscribes :restart, "git[#{work_dir}]"
end

template "#{node[:nginx][:dir]}/sites-available/barmaid.conf" do
  source 'nginx.conf.erb'
  variables domain: node[:fqdn],
    htpasswd: htpasswd,
    socket: unicorn_socket
  notifies :reload, resources(service: 'nginx')
end

nginx_site 'barmaid' do
  action :enable
end

log_files = [
  "unicorn.log",
  "resque.log",
  "unicorn.stdout.log",
  "unicorn.stderr.log"
].map { |l| "#{shared_dir}/#{l}" }

logrotate 'barmaid' do
  files log_files
  frequency 'daily'
  rotate_count 3
  compress true
  user 'barman'
  group 'barman'
  restart_command '/usr/local/bin/eye restart barmaid'
end
