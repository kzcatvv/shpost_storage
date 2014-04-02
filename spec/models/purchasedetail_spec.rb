require 'spec_helper'

describe Purchasedetail do
  #pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with a name" do
		expect(FactoryGirl.build(:purchasedetail)).to be_valid
	end

	it "is invalid without a name" do
		expect(FactoryGirl.build(:invalid_purchasedetail)).to have(1).errors_on(:name)
	end

end
