class RemoveIndexOnEmailFromUsers < ActiveRecord::Migration
  def up
    change_column :users, :email, :string,:null => true, :default => nil
    remove_index  :users, :email
  end

  def down
    change_column :users, :email, :string,:null => false, :default => ""
    add_index :users, :email, :unique => true
  end
end
