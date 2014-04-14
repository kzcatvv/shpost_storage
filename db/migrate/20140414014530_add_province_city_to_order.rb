class AddProvinceCityToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :province, :string
  	add_column :orders, :city, :string
  end
end
