class CreateSequenceNos < ActiveRecord::Migration
  def change
    create_table :sequence_nos do |t|
      t.integer :unit_id
      t.integer :storage_id
      t.integer :logistic_id
      t.string :start_no
      t.string :end_no
    end
  end
end
