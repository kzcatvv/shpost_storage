class AddOutAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :out_at, :datetime

    
    orders = Order.all
    orders.each do |o|
      if !o.keyclientorder_id.blank?
        if !UserLog.find_by(parent_id:o.keyclientorder_id,operation:['电商确认出库','批量确认出库']).blank?
          Order.update(o.id,out_at:UserLog.find_by(parent_id:o.keyclientorder_id,operation:['电商确认出库','批量确认出库']).created_at) 
        end
      end
    end
  end
end
