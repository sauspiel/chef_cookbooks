actions :add

def initialize(*args)
  super
  @action = :add
end

attribute :ds_name, :kind_of => String, :name_attribute => true
attribute :ds_type, :kind_of => String
attribute :min, :kind_of => Integer, :default => 0
attribute :max, :kind_of => Integer, :default => 65535
