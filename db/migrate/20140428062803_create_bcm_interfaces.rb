class CreateBcmInterfaces < ActiveRecord::Migration
  def change
    create_table :bcm_interfaces do |t|

      t.timestamps
    end
  end
end
