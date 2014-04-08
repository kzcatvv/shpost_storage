class DelUnitIdToKeyclientorder < ActiveRecord::Migration
  def change
  	remove_column :keyclientorderdetails, :unit_id
  end
end
