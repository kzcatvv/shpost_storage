class AddVirtualToKeyclientorders < ActiveRecord::Migration
  def change
    add_column :keyclientorders, :virtual, :string, :default => "0"
  end
end
