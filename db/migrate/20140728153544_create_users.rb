class CreateUsers < ActiveRecord::Migration
  def change

    create_table :sites do |t|
      t.string :name
      t.boolean :deleted, default: false
      t.timestamps
    end

    create_table :roles do |t|
      t.string :name
      t.timestamps
    end

    create_table :users do |t|
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :phone
      t.belongs_to :role
      t.belongs_to :site
      t.timestamps
    end
  end
end
