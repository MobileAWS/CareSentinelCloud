class CustomerUser < ActiveRecord::Base
  attr_accessible :user, :user_attributes, :customer, :customer_attributes

  belongs_to :user
  belongs_to :customer

  accepts_nested_attributes_for :user, :customer
end