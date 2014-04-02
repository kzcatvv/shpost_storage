class Addnotospecification < ActiveRecord::Migration
  def change
  	add_column :specifications, :product_no, :string
  end
end
