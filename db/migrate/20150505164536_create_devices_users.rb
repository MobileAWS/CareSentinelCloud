class CreateDevicesUsers < ActiveRecord::Migration
  def change
    create_table :site_users do |t|
       t.belongs_to :site
       t.belongs_to :user
    end

    create_table :customer_users do |t|
      t.belongs_to :customer
      t.belongs_to :user
    end

    create_table :device_properties do |t|
      t.belongs_to :device_mapping
      t.belongs_to :property
      t.string :value, null: false
      t.timestamps
    end

    create_table :device_mappings do |t|
      t.belongs_to :device
      t.belongs_to :site
      t.belongs_to :user
      t.belongs_to :customer
      t.boolean :enable, null: false, default: true
    end

    add_index :site_users, [:site_id, :user_id], :unique => true
    add_index :device_mappings, [:device_id, :site_id, :user_id, :customer_id], :unique => true, name: 'unique_device_mapping'
  end
end
