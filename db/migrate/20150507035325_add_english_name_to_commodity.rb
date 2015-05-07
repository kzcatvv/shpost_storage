class AddEnglishNameToCommodity < ActiveRecord::Migration
  def change
    add_column :commodities, :english_name, :string
  end
end
