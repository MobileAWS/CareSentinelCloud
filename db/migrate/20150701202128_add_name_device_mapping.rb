class AddNameDeviceMapping < ActiveRecord::Migration
  def change
    add_column :device_mappings,:device_name, :string, null: false
  end
end
