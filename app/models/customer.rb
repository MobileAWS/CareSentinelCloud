
class Customer < ActiveRecord::Base

  attr_accessible :customer_id, :description
  @@gridColumns = {:id => "Id", :customer_id => "Customer ID", :description => "Description", :created_at => "Created At"}

  @@columnOrder = {:created_at => "desc"}

  @@gridRenderers = {:created_at => 'dateRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.columnOrder
    @@columnOrder
  end

  def self.gridRenderers
    @@gridRenderers
  end
end