class AddIndexToRolesUserIdStorageIdRole < ActiveRecord::Migration
  def change
  	add_index :roles, [:user_id, :storage_id, :role], unique: true
  end
end
