require 'spec_helper'

describe Area do
  it "is valid with a area_code and desc" do
  	expect(FactoryGirl.build(:area)).to be_valid
  end

  it "is invalid without a area_code" do
  	expect(FactoryGirl.build(:area, area_code: nil)).to have(1).errors_on(:area_code)
  end

  it "is invalid without a desc" do
  	expect(FactoryGirl.build(:area, desc: nil)).to have(1).errors_on(:desc)
  end

  it "is invalid without a storage" do
    expect(FactoryGirl.build(:area, storage_id: nil)).to have(1).errors_on(:storage_id)
  end
end
