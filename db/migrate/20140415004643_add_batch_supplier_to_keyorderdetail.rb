class AddBatchSupplierToKeyorderdetail < ActiveRecord::Migration
  def change
  	add_column :keyclientorderdetails, :batch_no, :string
  	add_column :keyclientorderdetails, :supplier_id, :integer
  end
end
