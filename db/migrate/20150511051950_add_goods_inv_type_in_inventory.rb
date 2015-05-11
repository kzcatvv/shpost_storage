class AddGoodsInvTypeInInventory < ActiveRecord::Migration
  def change
  	add_column :inventories, :goods_inv_type, :string
  	add_column :inventories, :goods_inv_dtl, :string
  end
end
