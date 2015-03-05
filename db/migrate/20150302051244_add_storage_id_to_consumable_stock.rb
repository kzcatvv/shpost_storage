class AddStorageIdToConsumableStock < ActiveRecord::Migration
  def change
  	add_column :consumable_stocks, :unit_id, :integer
  	add_column :consumable_stocks, :storage_id, :integer
  end
end
