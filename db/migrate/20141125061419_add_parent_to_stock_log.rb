class AddParentToStockLog < ActiveRecord::Migration
  def change
    change_table :stock_logs do |t|
      t.references :parent, polymorphic: true
    end
    StockLog.all.each do |x|
      x.update(parent: x.purchase_detail.purchase) if x.belongs_to_purchase?
      x.update(parent: x.manual_stock_detail.manual_stock) if x.belongs_to_manual_stock?
      x.update(parent: x.orders.first.keyclientorder) if x.belongs_to_order?
    end
  end
end
