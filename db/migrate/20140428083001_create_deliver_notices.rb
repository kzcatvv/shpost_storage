class CreateDeliverNotices < ActiveRecord::Migration
  def change
    create_table :deliver_notices do |t|
        t.integer :order_id
        t.string :status
        t.string :send_type
        t.integer :send_times,  default: 0
        t.timestamps
    end
  end
end
