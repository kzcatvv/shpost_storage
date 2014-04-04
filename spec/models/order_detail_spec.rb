require 'spec_helper'

describe OrderDetail do
  #pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with a no" do
		expect(FactoryGirl.build(:order_detail)).to be_valid
	end

	it "is invalid without a no" do
		expect(FactoryGirl.build(:invalid_order_detail)).to have(1).errors_on(:name)
	end

end
