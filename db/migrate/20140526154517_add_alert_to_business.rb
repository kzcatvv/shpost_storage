class AddAlertToBusiness < ActiveRecord::Migration
  def change
  	add_column :businesses, :alertday, :integer, :default => 0
  end
end
