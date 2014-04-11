class Createorderdtlstocklogjointable < ActiveRecord::Migration
  def change
  	create_table :order_details_stock_logs, id: false do |t|
      t.column "order_detail_id", :integer, :null => false  
      t.column "stock_log_id",  :integer, :null => false
    end
  end
end
