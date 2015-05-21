class DeviceUser < ActiveRecord::Base
  attr_accessible :enable, :device, :device_attributes, :user, :user_attributes

  belongs_to :device
  belongs_to :user

  accepts_nested_attributes_for :user, :device
end