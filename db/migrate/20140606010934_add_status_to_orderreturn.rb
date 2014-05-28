class AddStatusToOrderreturn < ActiveRecord::Migration
  def change
  	add_column :orderreturns, :status, :string
  end
end
