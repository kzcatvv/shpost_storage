class DelStorageInLogistics < ActiveRecord::Migration
  def change
  	remove_column :logistics, :storage_id
  end
end
