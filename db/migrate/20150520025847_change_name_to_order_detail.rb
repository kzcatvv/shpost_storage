class ChangeNameToOrderDetail < ActiveRecord::Migration
  def change
  	change_column(:order_details, :name, :string, :null => true, :default => '')
  end
end
