actions :create, :delete
default_action :create
 
attribute :name, :kind_of => String, :name_attribute => true
attribute :status, :kind_of => String
attribute :run_levels, :kind_of => Array
attribute :init_actions, :kind_of => Array
attribute :default_policy

# Covers 0.10.8 and earlier
def initialize(*args)
  super
  @action = :create
end
