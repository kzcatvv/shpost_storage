class AddWarningAmtToRelationship < ActiveRecord::Migration
  def change
  	add_column :relationships, :warning_amt, :integer
  end
end
