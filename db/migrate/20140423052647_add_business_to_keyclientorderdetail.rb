class AddBusinessToKeyclientorderdetail < ActiveRecord::Migration
  def change
  	add_column :keyclientorderdetails, :business_id, :integer
  end
end
