class SiteUser < ActiveRecord::Base
  attr_accessible :user, :user_attributes, :site, :site_attributes

  belongs_to :user
  belongs_to :site

  accepts_nested_attributes_for :user, :site
end