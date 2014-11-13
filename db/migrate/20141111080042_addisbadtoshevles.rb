class Addisbadtoshevles < ActiveRecord::Migration
  def change
  	add_column :shelves, :is_bad, :string,:default => "no"
  end
end
