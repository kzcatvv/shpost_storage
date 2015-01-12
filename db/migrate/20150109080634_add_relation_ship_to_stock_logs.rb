class AddRelationShipToStockLogs < ActiveRecord::Migration
  def change
    add_column :stock_logs, :relationship_id, :inter
  end
end
