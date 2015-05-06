class AddWlnoToLogistics < ActiveRecord::Migration
  def change
  	add_column :logistics, :wl_no, :string
  end
end
