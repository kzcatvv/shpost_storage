class CreatePurchaseArrives < ActiveRecord::Migration
  def change
    create_table :purchase_arrives do |t|
      t.integer :arrived_amount
      t.string :expiration_date
      t.string :date
      t.string :arrived_date
      t.string :date
      t.string :batch_no
      t.string :string
      t.string :purchase_detail_id
      t.string :integer

      t.timestamps
    end
  end
end
