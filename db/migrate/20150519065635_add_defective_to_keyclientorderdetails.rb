class AddDefectiveToKeyclientorderdetails < ActiveRecord::Migration
  def change
    add_column :keyclientorderdetails, :defective, :string, :default => "0"
  end
end
