class RenameIsParentToIsSplitOnOrder < ActiveRecord::Migration
  def change
  	rename_column :orders, :is_parent, :is_split
  end
end
