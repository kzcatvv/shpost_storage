require 'spec_helper'

describe Shelf do
  it "is valid with a full info" do
  	expect(FactoryGirl.build(:shelf)).to be_valid
  end

  it "is invalid without a shelf_code" do
  	expect(FactoryGirl.build(:shelf, shelf_code: nil)).to have(1).errors_on(:shelf_code)
  end

  it "is invalid without a area_length" do
    expect(FactoryGirl.build(:shelf, area_length: nil)).to have(3).errors_on(:area_length)
  end

  it "is invalid without a area_width" do
    expect(FactoryGirl.build(:shelf, area_width: nil)).to have(3).errors_on(:area_width)
  end

  it "is invalid without a area_height" do
    expect(FactoryGirl.build(:shelf, area_height: nil)).to have(3).errors_on(:area_height)
  end

  it "is invalid without a shelf_row" do
    expect(FactoryGirl.build(:shelf, shelf_row: nil)).to have(3).errors_on(:shelf_row)
  end

  it "is invalid without a shelf_column" do
    expect(FactoryGirl.build(:shelf, shelf_column: nil)).to have(3).errors_on(:shelf_column)
  end

  it "is invalid if the area_length is greater than 99" do
    expect(FactoryGirl.build(:shelf, area_length: 100)).to have(1).errors_on(:area_length)
  end

  it "is invalid if the area_width is greater than 99" do
    expect(FactoryGirl.build(:shelf, area_width: 100)).to have(1).errors_on(:area_width)
  end

  it "is invalid if the area_height is greater than 99" do
    expect(FactoryGirl.build(:shelf, area_height: 100)).to have(1).errors_on(:area_height)
  end

  it "is invalid if the shelf_row is greater than 99" do
    expect(FactoryGirl.build(:shelf, shelf_row: 100)).to have(1).errors_on(:shelf_row)
  end

  it "is invalid if the shelf_column is greater than 99" do
    expect(FactoryGirl.build(:shelf, shelf_column: 100)).to have(1).errors_on(:shelf_column)
  end

  it "is invalid if the area_length is not a number" do
    expect(FactoryGirl.build(:shelf, area_length: 'a')).to have(2).errors_on(:area_length)
  end

  it "is invalid if the area_width is not a number" do
    expect(FactoryGirl.build(:shelf, area_width: 'a')).to have(2).errors_on(:area_width)
  end

  it "is invalid if the area_height is not a number" do
    expect(FactoryGirl.build(:shelf, area_height: 'a')).to have(2).errors_on(:area_height)
  end

  it "is invalid if the shelf_row is not a number" do
    expect(FactoryGirl.build(:shelf, shelf_row: 'a')).to have(2).errors_on(:shelf_row)
  end

  it "is invalid if the shelf_column is not a number" do
    expect(FactoryGirl.build(:shelf, shelf_column: 'a')).to have(2).errors_on(:shelf_column)
  end

  it "is invalid without a max_weight" do
    expect(FactoryGirl.build(:shelf, max_weight: nil)).to have(1).errors_on(:max_weight)
  end

  it "is invalid without a max_volume" do
    expect(FactoryGirl.build(:shelf, max_volume: nil)).to have(1).errors_on(:max_volume)
  end

  it "is valid without a desc" do
  	expect(FactoryGirl.build(:shelf, desc: nil)).to be_valid
  end

  it "is invalid without a area" do
    expect(FactoryGirl.build(:shelf, area_id: nil)).to have(1).errors_on(:area_id)
  end
end
