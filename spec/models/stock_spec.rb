require 'spec_helper'

describe Stock do
  it "is valid with specification_id actual_amount virtual_amount" do
    expect(FactoryGirl.build(:stock)).to be_valid
  end

  it "is invalid without a actual_amount" do
    expect(FactoryGirl.build(:invalid_without_aa_stock)).to have(1).errors_on(:actual_amount)
  end

  it "is invalid without a virtual_amount" do
    expect(FactoryGirl.build(:invalid_without_va_stock)).to have(1).errors_on(:virtual_amount)
  end

  it "is invalid without a specification_id" do
    expect(FactoryGirl.build(:invalid_without_specification_stock)).to have(1).errors_on(:specification_id)
  end
end
