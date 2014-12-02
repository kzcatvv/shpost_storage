class ChangeNoToOrders < ActiveRecord::Migration
  def change
  	change_column :orders, :no, :string, :null => true
  end
end
