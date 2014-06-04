class AddBatchIdToOrderreturn < ActiveRecord::Migration
  def change
  	add_column :orderreturns, :batch_id, :string
  end
end
