require 'spec_helper'

describe User do
  it "is valid with a username, name, password and role" do
  	expect(FactoryGirl.build(:user)).to be_valid
  end

  it "is invalid without a username" do
  	expect(FactoryGirl.build(:user, username: nil)).to have(1).errors_on(:username)
  end

  it "is invalid without a name" do
  	expect(FactoryGirl.build(:user, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a password" do
  	expect(FactoryGirl.build(:user, password: nil)).to have(1).errors_on(:password)
  end

  it "is invalid without a role" do
  	expect(FactoryGirl.build(:user, role: nil)).to have(1).errors_on(:role)
  end

  describe "superadmin check" do
  	context "is superadmin" do
  		it "return true" do
  			superadmin = FactoryGirl.build(:superadmin)
  			expect(superadmin.superadmin?).to be_true
  		end
  	end

  	context "isn't superadmin" do
  		it "return false" do
  			user = FactoryGirl.build(:user)
  			expect(user.superadmin?).to_not be_true
  		end
  	end
  end


end
