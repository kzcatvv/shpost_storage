class AddVolumeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :volume, :float
  end
end
