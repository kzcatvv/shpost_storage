class AddIsParentToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :is_parent, :boolean,:default => false
  end
end
