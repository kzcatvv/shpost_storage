require 'spec_helper'

describe Purchase do
  #pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with a no" do
		expect(FactoryGirl.build(:purchase)).to be_valid
	end

	it "is invalid without a no" do
		expect(FactoryGirl.build(:invalid_purchase)).to have(1).errors_on(:no)
	end

  it "is invalid without a name" do
    expect(FactoryGirl.build(:purchase, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid with a string sum" do
    expect(FactoryGirl.build(:purchase, sum: 'sum')).to have(1).errors_on(:sum)
  end

  it "is invalid with a string amount" do
    expect(FactoryGirl.build(:purchase, amount: 'amount')).to have(1).errors_on(:amount)
  end

  it "is invalid with a float amount" do
    expect(FactoryGirl.build(:purchase, amount: 20.5)).to have(1).errors_on(:amount)
  end

end
