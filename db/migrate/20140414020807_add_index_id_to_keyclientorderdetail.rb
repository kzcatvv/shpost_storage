class AddIndexIdToKeyclientorderdetail < ActiveRecord::Migration
  def change
  	add_index :keyclientorderdetails, [:keyclientorder_id, :specification_id], unique: true, name: 'index_on_keyorderdtl_id_specification'
  end
end
