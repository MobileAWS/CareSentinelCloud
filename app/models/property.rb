class Property < ActiveRecord::Base

  attr_accessible :created_at

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id", :key => "Sensor", :value => "State", :device_name => "Device Name", :created_at => 'Alerted At', :dismiss_time => "Acknowledged At"}

  @@gridRenderers = {:created_at => 'dateRenderer',:dismiss_time => 'dateRenderer'}

  @@columnOrder = {:created_at => "desc"}

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
