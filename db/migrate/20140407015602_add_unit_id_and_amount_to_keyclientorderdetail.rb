class AddUnitIdAndAmountToKeyclientorderdetail < ActiveRecord::Migration
  def change
  	add_column :keyclientorderdetails, :unit_id, :integer
  	add_column :keyclientorderdetails, :amount, :integer
  end
end
