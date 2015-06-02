class Device < ActiveRecord::Base

  belongs_to :device_mapping

  @@gridColumns = {:id => "Id",:name => "Device Name", :hw_id => "Hardware ID", :enable => "Enabled"}
  @@colActions = { :name =>
                       {:index => 1, :action => "/:id/properties" , :action_title => 'Properties', :html_template => '<a href="#" onclick="{onclick}">{data}</a>'},
                   :enable =>
                       {:index => 3, :action => "/:id/changestatus" , :html_template => '<input type="checkbox" onclick="{onclick}" {data}>'}
                 }
  @@gridRenderers = {:name => 'actionDialogRender', :enable => 'actionRender'}


  def self.colActions
    @@colActions
  end

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

end
