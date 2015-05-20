class AddDefectiveToPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :purchase_details, :defective, :string, :default => "0"
  end
end
