class AddBarcodeToSpecifications < ActiveRecord::Migration
  def change
    add_column :specifications, :barcode, :string
    add_column :specifications, :no, :string
  end
end
