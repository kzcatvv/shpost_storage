class AddTypeToKeyclientorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :key_type, :string
  end
end
