class AddTrackingInfoToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :tracking_info, :string
  end
end
