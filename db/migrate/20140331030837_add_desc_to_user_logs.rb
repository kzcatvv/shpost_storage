class AddDescToUserLogs < ActiveRecord::Migration
  def change
    add_column :user_logs, :desc, :string
  end
end
