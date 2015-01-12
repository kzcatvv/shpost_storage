class AddAssignTypeToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :assign_type, :string
  end
end
