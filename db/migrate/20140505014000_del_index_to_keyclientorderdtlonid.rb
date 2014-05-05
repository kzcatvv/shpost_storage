class DelIndexToKeyclientorderdtlonid < ActiveRecord::Migration
  def change
  	remove_index :keyclientorderdetails, name: 'index_on_keyorderdtl_id_specification'
  end
end
