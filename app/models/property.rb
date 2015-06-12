class Property < ActiveRecord::Base

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id",:key => "Property Name", :metric => "Metric", :value => "Value", :created_at => "Created At"}

  def self.gridColumns
    @@gridColumns
  end
end
