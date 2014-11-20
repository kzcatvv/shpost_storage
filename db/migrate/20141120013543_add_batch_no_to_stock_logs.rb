class AddBatchNoToStockLogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :expiration_date, :date
    add_column :stock_logs, :batch_no, :string
  end
end
