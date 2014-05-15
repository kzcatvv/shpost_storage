class Addindextoorderdetailsstocklogs < ActiveRecord::Migration
  def change
  	add_index :order_details_stock_logs, [:order_detail_id, :stock_log_id], name: 'od_sl_by_id',:unique => true
  end
end
