class CreateInterfaceInfos < ActiveRecord::Migration
  def change
    create_table :interface_infos do |t|
      t.string :method_name
      t.string :class_name
      t.string :status
      t.string :operate_time
      t.string :url
      t.string :url_method
      t.text :url_content
      t.string :type

      t.timestamps
    end
  end
end
