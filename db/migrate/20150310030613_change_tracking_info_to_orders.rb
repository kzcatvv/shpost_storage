class ChangeTrackingInfoToOrders < ActiveRecord::Migration
  def change
    change_column :orders, :tracking_info, :string, :limit => 4000, :null => true, :default => nil
  end
end
