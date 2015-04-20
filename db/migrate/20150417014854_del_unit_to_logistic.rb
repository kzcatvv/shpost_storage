class DelUnitToLogistic < ActiveRecord::Migration
  def change
  	remove_column :logistics, :unit_id
  end
end
