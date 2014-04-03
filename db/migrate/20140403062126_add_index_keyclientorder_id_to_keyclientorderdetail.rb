class AddIndexKeyclientorderIdToKeyclientorderdetail < ActiveRecord::Migration
  def change
  	add_index :keyclientorderdetails, [:keyclientorder_id], unique: true
  end
end
