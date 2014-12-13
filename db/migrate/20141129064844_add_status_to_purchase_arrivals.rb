class AddStatusToPurchaseArrivals < ActiveRecord::Migration
  def change
  	add_column :purchase_arrivals, :status, :string
  end
end
