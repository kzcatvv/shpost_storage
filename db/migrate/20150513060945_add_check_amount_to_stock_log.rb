class AddCheckAmountToStockLog < ActiveRecord::Migration
  def change
  	add_column :stock_logs, :check_amount, :integer, default: 0
  end
end
