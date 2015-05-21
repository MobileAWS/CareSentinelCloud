class CreateUsers < ActiveRecord::Migration
  def change

    create_table :sites do |t|
      t.string :name
      t.boolean :deleted, default: false
      t.timestamps
    end

    create_table :roles do |t|
      t.string :name
      t.string :role_id, null: false
      t.timestamps
    end

    create_table :users do |t|
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :phone
      t.integer :customer_id, null: false
      t.belongs_to :role
      t.timestamps
    end

    create_table :site_configs do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.string :job_id, default: ''
      t.belongs_to :site, null: false
      t.timestamps
    end

    add_index(:users, :customer_id, unique: true)
  end
end
