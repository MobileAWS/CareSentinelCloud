class AddCustomerInformation < ActiveRecord::Migration
  def change
    execute %Q{CREATE SEQUENCE "customers_ids_sequence" START 100000001;}
  end
end
