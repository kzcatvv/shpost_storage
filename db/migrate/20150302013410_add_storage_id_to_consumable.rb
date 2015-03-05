class AddStorageIdToConsumable < ActiveRecord::Migration
  def change
  	add_column :consumables, :unit_id, :integer
  	add_column :consumables, :storage_id, :integer
  end
end
