require 'spec_helper'

feature 'userlog manage' do
	scenario 'user sign_in and sign_out' do

		FactoryGirl.create(:unit)
      	@user = FactoryGirl.create(:user)
      	@superadmin = FactoryGirl.create(:superadmin)
      	@unitadmin = FactoryGirl.create(:unitadmin)

		visit new_user_session_path																																							
		expect {
		fill_in 'user_username', with: 'superadmin_test'
		fill_in 'user_password', with: '11111111'

		click_button 'Sign in'
		}.to change(UserLog, :count).by(1)

		expect {click_link '退出'}.to change(UserLog, :count).by(1)

		save_and_open_page
	end
end