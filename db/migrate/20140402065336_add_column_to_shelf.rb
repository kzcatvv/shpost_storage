class AddColumnToShelf < ActiveRecord::Migration
  def change
  	add_column :shelves, :vertical, :integer, :null => false, :default => 1
  	add_column :shelves, :horizontal, :integer, :null => false, :default => 1
  	add_column :shelves, :shelf_row, :integer, :null => false, :default => 1
  	add_column :shelves, :shelf_column, :integer, :null => false, :default => 1
  	add_column :shelves, :max_weight, :integer, :null => false, :default => 0
  	add_column :shelves, :max_volume, :integer, :null => false, :default => 0
  end
end
