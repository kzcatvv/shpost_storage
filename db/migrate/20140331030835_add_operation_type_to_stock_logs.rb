class AddOperationTypeToStockLogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :operation_type, :string
  end
end
