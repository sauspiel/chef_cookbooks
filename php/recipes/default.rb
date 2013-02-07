include_recipe 'apt'

apt_repository "dotdeb" do
  uri "http://packages.dotdeb.org"
  components ["all"]
  distribution "stable"
  key "http://www.dotdeb.org/dotdeb.gpg"
  action :add
end

template "/etc/apt/preferences.d/dotdeb" do
  source "apt-preferences.cfg.erb"
  mode 0644
  owner "root"
  group "root"
end

%w(php5 libapache2-mod-php5 php5-fpm).each do |pkg|
  package pkg do
    action :install
  end
end

%w(apache2 cli fpm).each do |dir|

  directory "/etc/php5/#{dir}"

  template "/etc/php5/#{dir}/php.ini" do
    source "php.ini.erb"
    owner "root"
    group "root"
    mode 0644
  end

end

service "php5-fpm" do
  supports [:reload, :restart]
end


service "php5-fpm" do
  action [:enable, :reload]
end
