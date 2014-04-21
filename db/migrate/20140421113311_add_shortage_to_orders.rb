class AddShortageToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :is_shortage, :string
  end
end
