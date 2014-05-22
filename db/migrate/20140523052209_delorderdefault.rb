class Delorderdefault < ActiveRecord::Migration
  def change
  	change_column :orders, :business_id, :integer, :null => true
  	change_column_default(:orders, :business_id, nil)
  	change_column :orders, :unit_id, :integer, :null => true
  	change_column_default(:orders, :unit_id, nil)
  	change_column :orders, :storage_id, :integer, :null => true
  	change_column_default(:orders, :storage_id, nil)
  	change_column :orders, :keyclientorder_id, :integer, :null => true
  	change_column_default(:orders, :keyclientorder_id, nil)
  end
end
