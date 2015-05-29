require 'master_cache'

class User < ActiveRecord::Base

  attr_accessible :email, :type
  devise :database_authenticatable, :registerable,:recoverable, :validatable, :confirmable

  belongs_to :role
  has_and_belongs_to_many :sites, join_table: "site_users"

  has_many :customer_users
  has_many :customers, :through => :customer_users

  @@gridColumns = {:id => "Id", :email => "Email", :role_name => "Role",:phone => "Phone"}
  @@gridRenderers = {:phone => 'phoneRenderer',:email => 'emailRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

  def isAdmin?
    return self.role.role_id == 'admin'
  end

  def isCaregiverAdmin?
    return self.role.role_id == 'caregiveradmin'
  end

  def isSiteLogin?
    return self.role.role_id == 'caregiver'
  end

  def valid_site?(site_id)
    return !self.sites.find_by(id: site_id).nil?
  end

  def valid_customer_id(customer_id)
    return !self.customers.find_by(customer_id: customer_id).nil?
  end

end
