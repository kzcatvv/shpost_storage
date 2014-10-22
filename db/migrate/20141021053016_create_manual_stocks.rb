class CreateManualStocks < ActiveRecord::Migration
  def change
    create_table :manual_stocks do |t|
      t.string :no
      t.string :name
      t.string :desc
      t.string :status
      t.integer :unit_id
      t.integer :business_id
      t.integer :storage_id

      t.timestamps
    end
  end
end
