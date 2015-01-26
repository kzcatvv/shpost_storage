class AddInvTypeDtlToInventory < ActiveRecord::Migration
  def change
  	add_column :inventories, :inv_type_dtl, :string
  end
end
