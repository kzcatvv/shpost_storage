class ChangeColumnAboutObjectToPurchaseDetailOnStockLogs < ActiveRecord::Migration
  def up
    remove_column :stock_logs, :object_symbol
    remove_column :stock_logs, :object_class
    rename_column :stock_logs, :object_primary_key, :purchase_detail_id
  end

  def down
    add_column :stock_logs, :object_symbol, :string
    add_column :stock_logs, :object_class, :string
    rename_column :stock_logs, :purchase_detail_id, :object_primary_key
  end
end
