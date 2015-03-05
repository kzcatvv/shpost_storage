class ChangeLastSignInTimeTypeToDatetimeOnMobile < ActiveRecord::Migration
  def change
    change_column :mobiles, :last_sign_in_time, :datetime
  end
end
