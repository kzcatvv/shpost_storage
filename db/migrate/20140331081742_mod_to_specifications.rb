class ModToSpecifications < ActiveRecord::Migration
  def change
  	remove_column :specifications, :size
  	remove_column :specifications, :color
  	add_column :specifications, :sixnine_code, :string
  	add_column :specifications, :desc, :string
  end
end
