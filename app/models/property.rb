class Property < ActiveRecord::Base

  attr_accessible :created_at

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id", :key => "Property Name", :metric => "Metric", :value => "Value", :device_name => "Device Name", :created_at => "Created At", :dismiss_time => "Dismiss Time"}

  def self.gridColumns
    @@gridColumns
  end
end
