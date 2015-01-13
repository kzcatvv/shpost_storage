class AddNeedPickToStorage < ActiveRecord::Migration
  def change
  	add_column :storages, :need_pick, :boolean, :default => false
  end
end
