class AddUnitIdToStorages < ActiveRecord::Migration
  def change
   add_column :storages, :unit_id, :integer 
  end
end
