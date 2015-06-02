class Session < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  belongs_to :customer
end
