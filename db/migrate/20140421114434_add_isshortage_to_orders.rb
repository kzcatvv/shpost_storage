class AddIsshortageToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :is_shortage, :string,:default => "no"
  end
end
