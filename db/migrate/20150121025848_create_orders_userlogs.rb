class CreateOrdersUserlogs < ActiveRecord::Migration
  def change
    create_table :orders_user_logs, :id =>false do |t|
      t.column "order_id", :integer, :null => false  
      t.column "user_log_id",  :integer, :null => false
    end
  end
end
