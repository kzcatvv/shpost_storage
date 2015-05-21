class AddReturnUnitToStorage < ActiveRecord::Migration
  def change
  	add_column :storages, :return_unit, :string, :default => "上海市邮政公司物流分公司"
  end
end
