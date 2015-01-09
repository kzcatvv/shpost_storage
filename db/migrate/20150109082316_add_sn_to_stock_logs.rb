class AddSnToStockLogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :sn, :string
  end
end
