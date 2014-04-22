class AddOperateorToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :Operateor, :integer
  end
end
