class DeviceMapping < ActiveRecord::Base

  attr_accessible :device, :device_attributes, :site, :site_attributes, :user, :user_attributes, :customer, :customer_attributes

  belongs_to :device
  belongs_to :site
  belongs_to :user
  belongs_to :customer

end
