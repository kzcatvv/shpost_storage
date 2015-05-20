class AddVirtualToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :virtual, :string, :default => "0"
  end
end
