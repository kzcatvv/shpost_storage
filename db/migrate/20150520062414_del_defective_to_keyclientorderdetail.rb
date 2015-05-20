class DelDefectiveToKeyclientorderdetail < ActiveRecord::Migration
  def change
    remove_column :keyclientorderdetails, :defective
  end
end
