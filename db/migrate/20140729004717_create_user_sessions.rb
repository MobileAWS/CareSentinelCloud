class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :sessions, id: false do |t|
      t.string :token
      t.belongs_to :user
      t.belongs_to :site
      t.timestamps
    end
    execute %Q{ ALTER TABLE "sessions" ADD PRIMARY KEY ("token"); }
  end
end
