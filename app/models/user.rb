require 'master_cache'

class User < ActiveRecord::Base

  attr_accessible :email, :firstname, :lastname, :type
  devise :database_authenticatable, :registerable,:recoverable, :validatable, :confirmable

  belongs_to :role
  belongs_to :site

  @@gridColumns = {:id => "Id", :firstname => "First Name",:lastname => "Last Name", :phone => "Phone",:email => "Email"}
  @@gridRenderers = {:phone => 'phoneRenderer',:email => 'emailRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

  def attributes
    tmpAttributes = super
    tmpAttributes[:full_name] = full_name if tmpAttributes[:full_name].nil?
    return tmpAttributes
  end

  def isAdmin?
    return self.role_id == 1 #Role 1 is admin
  end

  def full_name
    firstname + " " +lastname;
  end
end
