class AddCountyToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :county,  :string
  end 
end
