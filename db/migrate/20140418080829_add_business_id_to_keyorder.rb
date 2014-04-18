class AddBusinessIdToKeyorder < ActiveRecord::Migration
  def change
  	add_column :keyclientorders, :business_id, :integer
  end
end
