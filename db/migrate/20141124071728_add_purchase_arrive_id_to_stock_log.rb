class AddPurchaseArriveIdToStockLog < ActiveRecord::Migration
  def change
    add_column :stock_logs, :purchase_arrive_id, :integer
  end
end
