class AddBatchIdToKeyclientorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :batch_id, :string
  end
end
