class AddBarcodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :barcode, :string
    add_column :orders, :batch_no, :string
  end
end
