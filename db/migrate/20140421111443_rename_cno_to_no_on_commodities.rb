class RenameCnoToNoOnCommodities < ActiveRecord::Migration
  def change
    rename_column :commodities, :cno, :no
  end
end
