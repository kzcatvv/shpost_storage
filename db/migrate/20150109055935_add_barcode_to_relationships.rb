class AddBarcodeToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :barcode, :string
  end
end
