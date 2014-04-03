class AddNameToSpecifications < ActiveRecord::Migration
  def change
    add_column :specifications, :name, :string
  end
end
