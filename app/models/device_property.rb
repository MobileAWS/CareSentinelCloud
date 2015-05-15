class DeviceProperty < ActiveRecord::Base
  attr_accessible :value, :device, :device_attributes

  belongs_to :device
  belongs_to :property

  accepts_nested_attributes_for :property, :device
end