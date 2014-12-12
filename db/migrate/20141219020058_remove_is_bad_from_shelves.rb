class RemoveIsBadFromShelves < ActiveRecord::Migration
  def change
    remove_column :shelves, :is_bad, :string
  end
end
