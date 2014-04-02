require 'spec_helper'

describe Shelf do
  it "is valid with a shelf_code and desc" do
  	expect(FactoryGirl.build(:shelf)).to be_valid
  end

  it "is invalid without a shelf_code" do
  	expect(FactoryGirl.build(:shelf, shelf_code: nil)).to have(1).errors_on(:shelf_code)
  end

  it "is valid without a desc" do
  	expect(FactoryGirl.build(:shelf, desc: nil)).to be_valid
  end

  it "is invalid without a area" do
    expect(FactoryGirl.build(:shelf, area_id: nil)).to have(1).errors_on(:area_id)
  end
end
