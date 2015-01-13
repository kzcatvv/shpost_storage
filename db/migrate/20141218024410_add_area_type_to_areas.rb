class AddAreaTypeToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :area_type, :string

    Area.where(is_bad: 'yes').update_all(area_type: 'broken')
  end
end
