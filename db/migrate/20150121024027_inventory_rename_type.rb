class InventoryRenameType < ActiveRecord::Migration
  def change
  	rename_column :inventories, :type, :inv_type
  end
end
