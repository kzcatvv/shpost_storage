class AddEnglishNameToSpecification < ActiveRecord::Migration
  def change
    add_column :specifications, :english_name, :string
  end
end
