class ChangeColumnToShelves < ActiveRecord::Migration
  def change
  	change_column(:shelves, :area_length, :string, :null => true, :default => '')
  	change_column(:shelves, :area_width, :string, :null => true, :default => '')
  	change_column(:shelves, :area_height, :string, :null => true, :default => '')
  	change_column(:shelves, :shelf_row, :string, :null => true, :default => '')
  	change_column(:shelves, :shelf_column, :string, :null => true, :default => '')
  end
end
