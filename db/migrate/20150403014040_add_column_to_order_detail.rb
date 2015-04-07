class AddColumnToOrderDetail < ActiveRecord::Migration
  def change
  	add_column :order_details, :is_shortage, :string
  end
end
