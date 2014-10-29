class AddBarcodeToKeyclientorders < ActiveRecord::Migration
  def change
    add_column :keyclientorders, :barcode, :string
    add_column :keyclientorders, :no, :string
    rename_column :keyclientorders, :batch_id, :batch_no
  end
end
