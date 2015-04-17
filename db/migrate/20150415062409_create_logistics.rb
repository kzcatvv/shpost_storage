class CreateLogistics < ActiveRecord::Migration
  def change
    create_table :logistics do |t|
      t.string :name
      t.string :print_format
      t.boolean :is_getnum
      t.string :contact
      t.string :address
      t.string :contact_phone
      t.string :post
      t.boolean :is_default

      t.timestamps
    end
  end
end
