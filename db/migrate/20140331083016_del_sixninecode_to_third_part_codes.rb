class DelSixninecodeToThirdPartCodes < ActiveRecord::Migration
  def change
  	remove_column :thirdpartcodes, :sixnine_code
  end
end
