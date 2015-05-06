class CreateCountryCodes < ActiveRecord::Migration
  def change
    create_table :country_codes do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :code
      t.string :surfmail_partition_no
      t.string :regimail_partition_no
      t.boolean :is_mail

      t.timestamps
    end
  end
end
