class AddBarcodeToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :barcode, :string
  end
end
