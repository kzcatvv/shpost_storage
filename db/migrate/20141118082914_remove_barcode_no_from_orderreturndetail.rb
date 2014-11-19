class RemoveBarcodeNoFromOrderreturndetail < ActiveRecord::Migration
  def change
  	remove_column :order_return_details, :barcode
  	remove_column :order_return_details, :no
  end
end
