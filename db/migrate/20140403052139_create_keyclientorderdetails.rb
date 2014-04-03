class CreateKeyclientorderdetails < ActiveRecord::Migration
  def change
    create_table :keyclientorderdetails do |t|
      t.integer :keyclientorder_id
      t.integer :specification_id
      t.string :desc

      t.timestamps
    end
  end
end
