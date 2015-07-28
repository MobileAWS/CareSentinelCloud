class AddSiteCustomerLabel < ActiveRecord::Migration
  def change
    add_column :sites,:description, :string, default:''
    add_column :customers,:description, :string, default:''
  end
end