class Site < ActiveRecord::Base
  extend DeleteableModel

  has_and_belongs_to_many :users, join_table: "site_users"

  @@gridColumns = {:id => "Id", :name => "Name",:created_at => "Created At"}
  @@gridRenderers = {:created_at => 'dateRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

end