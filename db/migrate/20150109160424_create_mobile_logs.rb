class CreateMobileLogs < ActiveRecord::Migration
  def change
    create_table :mobile_logs do |t|
      
      t.string :status
      t.string :operate_type
      t.string :request
      t.string :response
      t.string :request_ip
      t.string :response_ip
      t.string :request_params

      t.references :user
      t.references :storage
      t.references :unit
      t.references :mobile

      t.timestamps
    end
  end
end
