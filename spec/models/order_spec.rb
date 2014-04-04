require 'spec_helper'

describe Order do
  #pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with a no" do
		expect(FactoryGirl.build(:order)).to be_valid
	end

	it "is invalid without a no" do
		expect(FactoryGirl.build(:invalid_order)).to have(1).errors_on(:no)
	end

end
