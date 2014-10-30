class AddBarcodeToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :barcode, :string
  end
end
