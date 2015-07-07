class Device < ActiveRecord::Base

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id",:device_name => "Device Name", :hw_id => "Hardware ID", :created_at => "Created At"}

  @@columnOrder = {:created_at => "desc"}

  @@gridRenderers = {:created_at => 'dateRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

  def self.columnOrder
    @@columnOrder
  end

end
