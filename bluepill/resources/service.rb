actions :start, :stop, :enable, :disable, :load, :restart, :force_restart

attribute :service_name, :name_attribute => true
attribute :enabled, :default => false
attribute :running, :default => false
attribute :variables, :kind_of => Hash
attribute :supports, :default => { :restart => true, :status => true }
attribute :cookbook, :kind_of => String, :default => 'bluepill'
attribute :template, :kind_of => String, :default => 'service.init.sh.erb'
