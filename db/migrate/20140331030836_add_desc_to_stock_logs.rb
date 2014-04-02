class AddDescToStockLogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :desc, :string
  end
end
