class AddShelfTypeToShelves < ActiveRecord::Migration
  def change
    add_column :shelves, :shelf_type, :string, default: 'normal'

    Shelf.where(is_bad: 'yes').update_all(shelf_type: 'broken')
  end
end
