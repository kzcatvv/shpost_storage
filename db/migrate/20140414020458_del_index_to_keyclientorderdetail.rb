class DelIndexToKeyclientorderdetail < ActiveRecord::Migration
  def change
  	remove_index :keyclientorderdetails, [:keyclientorder_id]
  end
end
