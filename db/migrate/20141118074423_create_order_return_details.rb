class CreateOrderReturnDetails < ActiveRecord::Migration
  def change
    create_table :order_return_details do |t|
      t.string :order_return_id
      t.string :integer
      t.string :order_detail_id
      t.string :integer
      t.string :return_reason
      t.string :string
      t.string :is_bad
      t.string :string
      t.string :created_at
      t.string :datetime
      t.string :updated_at
      t.string :datetime
      t.string :batch_no
      t.string :string
      t.string :status
      t.string :string
      t.string :barcode
      t.string :string
      t.string :no
      t.string :string

      t.timestamps
    end
  end
end
