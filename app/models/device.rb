class Device < ActiveRecord::Base

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id",:device_name => "Device Name", :hw_id => "Hardware ID", :created_at => "Create Date"}

  @@columnOrder = {:created_at => "desc"}


  def self.gridColumns
    @@gridColumns
  end

  def self.columnOrder
    @@columnOrder
  end

end
