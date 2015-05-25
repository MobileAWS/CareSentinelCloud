class CreateDevicesUsers < ActiveRecord::Migration
  def change
    create_table :device_users do |t|
       t.belongs_to :device
       t.belongs_to :user
       t.boolean :enable, null: false, default: true
     end

    create_table :site_users do |t|
       t.belongs_to :site
       t.belongs_to :user
    end

    create_table :device_properties do |t|
      t.belongs_to :device
      t.belongs_to :property
      t.string :value, null: false
      t.timestamps
    end

    add_index :device_users, [:device_id, :user_id], :unique => true
    add_index :site_users, [:site_id, :user_id], :unique => true
  end
end
