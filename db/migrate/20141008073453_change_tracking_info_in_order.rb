class ChangeTrackingInfoInOrder < ActiveRecord::Migration
  def change
    change_column :orders, :tracking_info, :string, :limit => 2000, :null => true, :default => nil
  end
end
