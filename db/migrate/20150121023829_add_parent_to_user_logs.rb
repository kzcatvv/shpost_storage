class AddParentToUserLogs < ActiveRecord::Migration
  def change
    add_column :user_logs, :parent_id, :integer
    add_column :user_logs, :parent_type, :string
  end
end
