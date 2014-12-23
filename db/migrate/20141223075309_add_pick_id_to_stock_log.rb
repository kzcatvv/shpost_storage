class AddPickIdToStockLog < ActiveRecord::Migration
  def change
  	add_column :stock_logs, :pick_id, :integer
  end
end
