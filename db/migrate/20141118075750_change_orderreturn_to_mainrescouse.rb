class ChangeOrderreturnToMainrescouse < ActiveRecord::Migration
  def change
  	remove_column :order_returns, :order_detail_id
  	rename_column :order_returns, :return_reason, :unit_id
    change_column :order_returns, :unit_id, :integer
    rename_column :order_returns, :is_bad, :desc
    rename_column :order_returns, :batch_no, :storage_id
    change_column :order_returns, :storage_id, :integer
  end
end
