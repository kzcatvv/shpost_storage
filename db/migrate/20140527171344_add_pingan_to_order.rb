class AddPinganToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :pingan_ordertime, :string
  	add_column :orders, :pingan_operate, :string
  	add_column :orders, :customer_idnumber, :string
  end
end
