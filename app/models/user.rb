require 'master_cache'

class User < ActiveRecord::Base
  extend DeleteableModel

  attr_accessible :email, :type
  devise :database_authenticatable, :registerable,:recoverable, :validatable, :confirmable

  belongs_to :role
  has_and_belongs_to_many :sites, join_table: "site_users"

  has_many :customer_users
  has_many :customers, :through => :customer_users

  # Data for the initialization, this is required to send the initial email, and should not be used on any other case.
  @initialPassword = nil
  @initialCustomer = nil
  @initialSite = nil

  attr_accessor :initialPassword, :initialCustomer, :initialSite

  @@gridColumns = {:id => "Id", :email => "Email", :role_name => "Role", :customer_id => "Last Customer ID", :site_name => "Last Site"}
  @@gridRenderers = {:email => 'emailRenderer'}

  def self.gridColumns
    @@gridColumns
  end

  def self.gridRenderers
    @@gridRenderers
  end

  def isAdmin?
    return self.role.role_id == Role::ADMIN_ROLE_ID
  end

  def isCaregiverAdmin?
    return self.role.role_id == Role::CAREGIVER_ADMIN_ROLE_ID
  end

  def isSiteLogin?
    return self.role.role_id == Role::CAREGIVER_ROLE_ID
  end

  def valid_site?(site_name)
    return self.sites.where('upper(name) = :site_name',site_name: site_name.upcase).count > 0
  end

  def valid_customer_id(customer_id)
    return !self.customers.find_by(customer_id: customer_id).nil?
  end

end
