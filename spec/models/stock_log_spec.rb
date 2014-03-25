require 'spec_helper'

describe StockLog do
  it "is valid with operation" do
    expect(FactoryGirl.build(:stock_log)).to be_valid
  end

  it "is invalid without a operation" do
    expect(FactoryGirl.build(:stock_log, operation: nil)).to have(1).errors_on(:operation)
  end

  it "is invalid without a amount" do
    expect(FactoryGirl.build(:stock_log, amount: nil)).to have(1).errors_on(:amount)
  end
end
