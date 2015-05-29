
class Customer < ActiveRecord::Base

  attr_accessible :customer_id
  @@gridColumns = {:id => "Id", :customer_id => "Customer ID"}

  def self.gridColumns
    @@gridColumns
  end

end