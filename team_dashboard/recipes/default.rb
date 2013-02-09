user = node[:team_dashboard][:user]
group = node[:team_dashboard][:group]

app = search(:apps, "id:team_dashboard").first

env = node.chef_environment
env = 'development' if env == '_default'
if node[:active_applications] && node[:active_applications][:team_dashboard]
  env = node[:active_applications][:team_dashboard][:env] || env
end

domain = app["environments"][env]["domain"]
path = "/var/www/#{domain}"

directory path do
  owner user
  group group
  mode 0755
  action :create
  recursive true
end

%w(libxml2 libxml2-dev libxslt1.1 libxslt1-dev).each do |pkg|
  package pkg
end

execute "bundle" do
  user user
  cwd path
  command "bundle install --path vendor"
  action :nothing
end

bash "modifying_gemfile" do
  cwd path
  user user
  code <<-EOF
  echo 'gem "unicorn", "~> 4.0.1"' >> Gemfile
  EOF
  not_if "grep -q unicorn Gemfile"
  action :nothing
end

git path do
  repository "https://github.com/fdietz/team_dashboard.git"
  reference "master"
  user user
  group group
  action :checkout
  notifies :run, resources(:bash => "modifying_gemfile"), :immediately
  notifies :run, resources(:execute => "bundle"), :immediately
end

include_recipe "team_dashboard::database"


