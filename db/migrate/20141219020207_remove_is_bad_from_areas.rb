class RemoveIsBadFromAreas < ActiveRecord::Migration
  def change
    remove_column :areas, :is_bad, :string
  end
end
