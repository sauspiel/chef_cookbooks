apt_repository "pgdg" do
  uri "http://pgapt.debian.net" 
  distribution "squeeze-pgdg"
  components ["main"]
  keyserver "keys.gnupg.net"
  key "ACCC4CF8"
  action :add
  notifies :run, "execute[apt-get update]", :immediately
end


%w(python-psycopg2 python-argh python-dateutil python-argparse barman).each do |pkg|
  package pkg do
    action :install
  end
end
