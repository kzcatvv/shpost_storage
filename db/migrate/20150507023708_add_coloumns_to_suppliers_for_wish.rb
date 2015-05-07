class AddColoumnsToSuppliersForWish < ActiveRecord::Migration
  def change
    add_column :suppliers, :business_id, :string
    add_column :suppliers, :business_code, :string
  end
end
