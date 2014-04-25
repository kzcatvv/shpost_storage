class AddDefaultStorageToStorage < ActiveRecord::Migration
  def change
  	add_column :storages, :default_storage, :boolean, default: false
  end
end
