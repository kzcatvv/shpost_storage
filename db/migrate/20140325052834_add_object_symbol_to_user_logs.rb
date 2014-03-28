class AddObjectSymbolToUserLogs < ActiveRecord::Migration
  def change
    add_column :user_logs, :object_symbol, :string 
  end
end
