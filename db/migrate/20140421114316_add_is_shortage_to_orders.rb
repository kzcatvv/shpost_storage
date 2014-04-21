class AddIsShortageToOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :is_shortage
  end
end
