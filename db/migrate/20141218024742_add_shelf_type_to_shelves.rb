class AddShelfTypeToShelves < ActiveRecord::Migration
  def change
    add_column :shelves, :shelf_type, :string
  end
end
