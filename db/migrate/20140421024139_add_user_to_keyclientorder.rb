class AddUserToKeyclientorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :user_id, :integer
  end
end
