class Site < ActiveRecord::Base
  extend DeleteableModel

  @@gridColumns = {:id => "Id", :name => "Name",:created_at => "Created At"}
  @@gridRenderers = {:created_at => 'dateRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

  def self.getSiteName (tmpId)
    return nil if tmpId.nil?
    result = Site.find(tmpId);
    return result.name;
  end

end