class CreateThirdpartcodes < ActiveRecord::Migration
  def change
    create_table :thirdpartcodes do |t|
      t.integer :business_id
      t.integer :supplier_id
      t.integer :specification_id
      t.string :sixnine_code
      t.string :external_code

      t.timestamps
    end
  end
end
