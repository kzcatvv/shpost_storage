class AddStatusToKeyclientorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :status, :string
  end
end
