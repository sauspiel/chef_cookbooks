actions :allow_upgrade, :deny_upgrade

def initialize(*args)
  super
  @action = :deny_upgrade
end

attribute :pkg, :kind_of => String, :name_attribute => true 
