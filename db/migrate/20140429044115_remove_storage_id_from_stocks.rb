class RemoveStorageIdFromStocks < ActiveRecord::Migration
  def change
    remove_column :stocks, :storage_id
  end
end
