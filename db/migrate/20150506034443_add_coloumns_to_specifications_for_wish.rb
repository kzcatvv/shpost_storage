class AddColoumnsToSpecificationsForWish < ActiveRecord::Migration
  def change
    add_column :specifications, :name_en, :string
    add_column :specifications, :price, :float
  end
end
