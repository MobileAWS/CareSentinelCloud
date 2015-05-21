class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name, null: false
      t.belongs_to :site, null: false
      t.timestamps
    end

    create_table :properties do |t|
      t.string :key, null: false
      t.string :metric
      t.timestamps
    end
  end
end
