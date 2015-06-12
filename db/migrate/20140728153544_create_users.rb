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
      t.belongs_to :role
      t.boolean :deleted, default: false
      t.timestamps
    end

    create_table :customers do |t|
      t.string :customer_id, null: false
      t.timestamps
    end

    create_table :site_configs do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.string :job_id, default: ''
      t.belongs_to :site, null: false
      t.boolean :enabled, default: true
      t.timestamps
    end

    add_index(:roles, :name, unique: true)
    add_index(:sites, :name, unique: true)
  end
end
