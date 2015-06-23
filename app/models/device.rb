class Device < ActiveRecord::Base

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id",:name => "Device Name", :hw_id => "Hardware ID", :created_at => "Create Date"}
  @@colActions = { :name =>
                       {:index => 1, :action => "/:id/properties" , :action_title => 'Properties', :html_template => '<a href="#" onclick="{onclick}">{data}</a>'}
                 }
  @@gridRenderers = {:name => 'actionDialogRender', :enable => 'actionRender'}

  @@columnOrder = {:created_at => "desc"}


  def self.colActions
    @@colActions
  end

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
