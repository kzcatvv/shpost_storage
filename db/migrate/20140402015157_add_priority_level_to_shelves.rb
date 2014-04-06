class AddPriorityLevelToShelves < ActiveRecord::Migration
  def change
    add_column :shelves, :priority_level, :integer
  end
end
