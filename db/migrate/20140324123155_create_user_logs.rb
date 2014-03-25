class CreateUserLogs < ActiveRecord::Migration
  def change
    create_table :user_logs do |t|
      t.integer :user_id, :null => false, :default => 0
      t.string :operation, :null => false, :default => ""
      t.string :object_class
      t.integer :object_id

      t.timestamps
    end
  end
end
