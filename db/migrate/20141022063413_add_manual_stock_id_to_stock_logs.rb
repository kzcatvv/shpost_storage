class AddManualStockIdToStockLogs < ActiveRecord::Migration
  def change
  	add_column :stock_logs, :manual_stock_detail_id, :integer
  end
end
