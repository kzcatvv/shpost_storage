class AddKeyclientorderdetailIdToStockLog < ActiveRecord::Migration
  def change
  	add_column :stock_logs, :keyclientorderdetail_id, :integer
  end
end
