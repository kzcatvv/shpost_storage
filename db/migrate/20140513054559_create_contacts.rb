class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :desc
      t.integer :supplier_id

      t.timestamps
    end
  end
end