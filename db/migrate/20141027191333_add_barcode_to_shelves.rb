class AddBarcodeToShelves < ActiveRecord::Migration
  def change
    add_column :shelves, :barcode, :string
    add_column :shelves, :no, :string
  end
end
