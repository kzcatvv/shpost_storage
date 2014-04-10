class AddUnitStorageToKeyclientorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :unit_id, :integer
  	add_column :keyclientorders, :storage_id, :integer
  end
end
