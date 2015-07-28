class RemoveConstraintSiteConfig < ActiveRecord::Migration
  def change
    change_column :site_configs, :site_id, :integer,:null => true
  end
end
