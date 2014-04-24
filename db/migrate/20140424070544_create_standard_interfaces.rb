class CreateStandardInterfaces < ActiveRecord::Migration
  def change
    create_table :standard_interfaces do |t|

      t.timestamps
    end
  end
end
