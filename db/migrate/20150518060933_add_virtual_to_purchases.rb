class AddVirtualToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :virtual, :string, :default => "0"
  end
end
