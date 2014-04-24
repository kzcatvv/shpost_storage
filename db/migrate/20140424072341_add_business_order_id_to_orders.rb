class AddBusinessOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :business_order_id, :string
  end
end
