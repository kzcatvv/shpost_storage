class AddBarcodeToOrderReturns < ActiveRecord::Migration
  def change
    add_column :order_returns, :barcode, :string
    add_column :order_returns, :no, :string
    rename_column :order_returns, :batch_id, :batch_no
  end
end
