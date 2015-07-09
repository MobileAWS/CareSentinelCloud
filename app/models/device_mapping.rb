class DeviceMapping < ActiveRecord::Base

  attr_accessible :device, :device_attributes, :site, :site_attributes, :user, :user_attributes, :customer, :customer_attributes

  belongs_to :device
  belongs_to :site
  belongs_to :user
  belongs_to :customer


  @@gridColumns = {:id => "Id", :device_name => "Device Name", :hw_id => "Hardware ID", :created_at => "Create Date"}

  @@colActions = {:device_name =>
                      {:index => 1, :action => "deviceNameSelected('{data}', {id}, '{entity}');", :action_title => 'property', :html_template => '<a href="#" onclick="{action}">{data}</a>'}
  }

  @@gridRenderers = {:device_name => 'javaScriptRender', :enable => 'actionRender', :created_at => "dateRenderer"}

  @@columnOrder = {:created_at => "desc"}

  def self.gridRenderers
    @@gridRenderers
  end

  def self.columnOrder
    @@columnOrder
  end

  def self.colActions
    @@colActions
  end

  def self.gridColumns
    @@gridColumns
  end

end
