class AddColoumnsToOrderDetailsForWish < ActiveRecord::Migration
  def change
    add_column :order_details, :from_country, :string
    add_column :order_details, :weight, :float
  end
end
