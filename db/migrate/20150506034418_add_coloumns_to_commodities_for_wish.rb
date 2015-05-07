class AddColoumnsToCommoditiesForWish < ActiveRecord::Migration
  def change
    add_column :commodities, :name_en, :string
  end
end
