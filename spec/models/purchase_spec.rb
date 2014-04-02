require 'spec_helper'

describe Purchase do
  #pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with a no" do
		expect(FactoryGirl.build(:purchase)).to be_valid
	end

	it "is invalid without a no" do
		expect(FactoryGirl.build(:invalid_purchase)).to have(1).errors_on(:no)
	end

end
