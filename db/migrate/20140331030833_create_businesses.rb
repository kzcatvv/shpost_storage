class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name, null: false, default: ''
      t.string :email
      t.string :contactor
      t.string :phone
      t.string :address
      t.string :desc
      t.integer :unit_id

      t.timestamps
    end
  end
end
