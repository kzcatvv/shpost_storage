class DelVirtualToKeyclientorder < ActiveRecord::Migration
  def change
    remove_column :keyclientorders, :virtual
  end
end
