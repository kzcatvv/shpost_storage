require 'spec_helper'

describe Area do
  it "is valid with a name, area_code and desc" do
  	expect(FactoryGirl.build(:area)).to be_valid
  end

  it "is invalid without a name" do
    expect(FactoryGirl.build(:area, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a area_code" do
  	expect(FactoryGirl.build(:area, area_code: nil)).to have(1).errors_on(:area_code)
  end

  it "is valid without a desc" do
    expect(FactoryGirl.build(:area, desc: nil)).to be_valid
  end

  it "is invalid without a storage" do
    expect(FactoryGirl.build(:area, storage_id: nil)).to have(1).errors_on(:storage_id)
  end
end
