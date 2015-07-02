class AddDeviceProperties < ActiveRecord::Migration
  def change
    add_column :device_properties,:dismiss_time, :timestamp
    add_column :device_properties,:dismiss_duration, :timestamp
  end
end
