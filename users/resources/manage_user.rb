actions :create

attribute :cookbook, :kind_of => String, :default => "users"

def initialize(*args)
  super
  @action = :create
end
