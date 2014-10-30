class AddBarcodeToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :barcode, :string
  end
end
