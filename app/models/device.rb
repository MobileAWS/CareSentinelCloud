class Device < ActiveRecord::Base

  has_many :device_users
  has_many :user, :through =>  :device_users

  has_many :device_properties, :dependent => :delete_all
  has_many :properties, :through => :device_properties
  belongs_to :site

  @@gridColumns = {:id => "Id",:name => "Device Name", :enable => "Enabled"}
  @@colActions = { :name =>
                       {:index => 1, :action => "/:id/properties" , :action_title => 'Properties', :html_template => '<a href="#" onclick="{onclick}">{data}</a>'},
                   :enable =>
                       {:index => 2, :action => "/:id/changestatus" , :html_template => '<input type="checkbox" onclick="{onclick}" {data}>'}
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
