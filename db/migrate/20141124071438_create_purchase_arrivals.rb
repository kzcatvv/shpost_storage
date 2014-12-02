class CreatePurchaseArrivals < ActiveRecord::Migration
  def change
    create_table :purchase_arrivals do |t|
      t.integer :arrived_amount
      t.date :expiration_date
      t.date :arrived_at
      t.string :batch_no
      t.integer :purchase_detail_id

      t.timestamps
    end
  end
end
