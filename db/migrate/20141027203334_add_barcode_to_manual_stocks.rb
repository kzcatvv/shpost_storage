class AddBarcodeToManualStocks < ActiveRecord::Migration
  def change
    add_column :manual_stocks, :barcode, :string
  end
end
