class Property < ActiveRecord::Base
  has_many :device_properties
  has_many :devices, :through => :device_properties
end
