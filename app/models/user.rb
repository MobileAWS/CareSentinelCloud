require 'master_cache'

class User < ActiveRecord::Base

  attr_accessible :email, :type
  devise :database_authenticatable, :registerable,:recoverable, :validatable, :confirmable

  belongs_to :role
  has_and_belongs_to_many :sites, join_table: "site_users"

  has_many :device_users
  has_many :devices, :through =>  :device_users

  @@gridColumns = {:id => "Id",:customer_id => "Customer Id", :phone => "Phone",:email => "Email"}
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

  def valid_site?(site_id)
    return !self.sites.find_by(id: site_id).nil?
  end
end
