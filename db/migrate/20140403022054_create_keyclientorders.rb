class CreateKeyclientorders < ActiveRecord::Migration
  def change
    create_table :keyclientorders do |t|
      t.string :keyclient_name
      t.string :keyclient_addr
      t.string :contact_person
      t.string :phone
      t.string :desc

      t.timestamps
    end
  end
end
