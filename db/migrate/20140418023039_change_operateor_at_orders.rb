class ChangeOperateorAtOrders < ActiveRecord::Migration
  def change
  	rename_column :orders, :Operateor, :user_id
  end
end
