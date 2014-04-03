require 'spec_helper'

describe PurchaseDetail do
  #pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with a name" do
		expect(FactoryGirl.build(:purchase_detail)).to be_valid
	end

	it "is invalid without a name" do
		expect(FactoryGirl.build(:invalid_purchase_detail)).to have(1).errors_on(:name)
	end

end
