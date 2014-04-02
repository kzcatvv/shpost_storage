class ChangeColumnToArea < ActiveRecord::Migration
  def change
  	add_column :areas, :area_code, :string, null: false, default: ""
  	remove_column  :areas, :are_code
  end
end
