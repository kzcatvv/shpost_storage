require 'spec_helper'

describe UserLog do
  it "is valid with a user_id, operation" do
    expect(FactoryGirl.build(:user_log)).to be_valid
  end

  it "is invalid without a user_id" do
    expect(FactoryGirl.build(:user_log, user_id: nil)).to have(1).errors_on(:user_id)
  end

  it "is invalid without a operation" do
    expect(FactoryGirl.build(:user_log, operation: nil)).to have(1).errors_on(:operation)
  end

end
