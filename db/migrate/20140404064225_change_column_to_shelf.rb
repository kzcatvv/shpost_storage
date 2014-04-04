class ChangeColumnToShelf < ActiveRecord::Migration
  def change
  	add_column :shelves, :area_length, :integer, :null => false, :default => 1
  	add_column :shelves, :area_width, :integer, :null => false, :default => 1
  	add_column :shelves, :area_height, :integer, :null => false, :default => 1
  	remove_column :shelves, :vertical
  	remove_column :shelves, :horizontal
  end
end
