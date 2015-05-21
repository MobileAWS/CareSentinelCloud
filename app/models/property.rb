class Property < ActiveRecord::Base
  has_many :device_properties
  has_many :devices, :through => :device_properties

  def self.to_csv
    CSV.generate do |csv|
      csv << ["row", "of", "CSV", "data"]
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
 end
end
