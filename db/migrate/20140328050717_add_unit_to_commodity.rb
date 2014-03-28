class AddUnitToCommodity < ActiveRecord::Migration
  def change
  	add_column :commodities, :unit_id, :integer
  end
end
