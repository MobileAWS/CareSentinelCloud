require 'master_cache'

class User < ActiveRecord::Base

  attr_accessible :email, :type
  devise :database_authenticatable, :registerable,:recoverable, :validatable, :confirmable

  belongs_to :role
  belongs_to :site

  @@gridColumns = {:id => "Id",:customer_id => "Customer Id", :site_id => "Customer Site Id",:phone => "Phone",:email => "Email"}
  @@gridRenderers = {:phone => 'phoneRenderer',:email => 'emailRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end


  def isAdmin?
    return self.role_id == 1 #Role 1 is admin
  end
end
