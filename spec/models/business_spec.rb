require 'spec_helper'

describe Business do
	it "is valid with a name" do
		expect(FactoryGirl.build(:business)).to be_valid
	end

	it "is invalid without a name" do
		expect(FactoryGirl.build(:invalid_business)).to have(1).errors_on(:name)
	end

end
