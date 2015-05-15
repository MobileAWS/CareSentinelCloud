class Device < ActiveRecord::Base

  has_many :device_users
  has_many :user, :through =>  :device_users

  has_many :device_properties
  has_many :properties, :through => :device_properties
  belongs_to :site

  @@gridColumns = {:id => "Id",:name => "Device Name", :enable => "Status"}
  @@colActions = { :name =>
                       {:index => 1, :action => "/:id/properties" , :action_title => 'Properties', :html_template => '<a href="#" onclick="{onclick}">{data}</a>'},
                   :enable =>
                       {:index => 2, :action => "/:id/status" , :html_template => '<a href="#" onclick="{onclick}">{data}</a>'}
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
