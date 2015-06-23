class DeviceProperty < ActiveRecord::Base
  attr_accessible :value, :device_mapping, :device_mapping_attributes, :property, :created_at

  belongs_to :device_mapping
  belongs_to :property

  accepts_nested_attributes_for :device_mapping
end