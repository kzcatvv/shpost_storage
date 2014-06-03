class CreateOrderreturns < ActiveRecord::Migration
  def change
    create_table :orderreturns do |t|
      t.integer :order_detail_id
      t.string :return_reason
      t.string :is_bad

      t.timestamps
    end
  end
end
