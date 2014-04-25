class AddStorageIdToStock < ActiveRecord::Migration
  def change
  	add_column :stocks, :storage_id, :integer
  end
end
