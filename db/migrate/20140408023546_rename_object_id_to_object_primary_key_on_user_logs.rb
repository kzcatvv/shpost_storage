class RenameObjectIdToObjectPrimaryKeyOnUserLogs < ActiveRecord::Migration
  def change
    rename_column :user_logs, :object_id, :object_primary_key
  end
end
