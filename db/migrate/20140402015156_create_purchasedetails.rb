class CreatePurchasedetails < ActiveRecord::Migration
  def change
    create_table :purchasedetails do |t|
      t.string :name,null:false, default: ''
      t.integer :purchase_id
      t.integer :supplier_id
      t.integer :spec_id
      t.string :qg_period
      t.string :batch_no
      t.integer :amount
      t.float :sum
      t.string :desc
      t.string :status

      t.timestamps
    end
  end
end
