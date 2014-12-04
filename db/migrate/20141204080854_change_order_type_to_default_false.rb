class ChangeOrderTypeToDefaultFalse < ActiveRecord::Migration
  def change
  	change_column :orders, :order_type,:string,:default => "b2c"
  end
end
