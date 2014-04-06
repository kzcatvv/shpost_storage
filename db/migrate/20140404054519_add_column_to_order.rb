class AddColumnToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :business_id, :integer, :null => false, :default => 1
  	add_column :orders, :unit_id, :integer, :null => false, :default => 1
  	add_column :orders, :storage_id, :integer, :null => false, :default => 1
  	add_column :orders, :keyclientorder_id, :integer, :null => false, :default => 1
  	
  end
end
