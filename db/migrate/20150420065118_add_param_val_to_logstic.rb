class AddParamValToLogstic < ActiveRecord::Migration
  def change
  	add_column :logistics, :param_val1, :string
  	add_column :logistics, :param_val2, :string
  end
end
