class DelTypeToKeyclientorder < ActiveRecord::Migration
  def change
  	remove_column :keyclientorders, :key_type
  end
end
