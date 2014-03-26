require 'spec_helper'

describe Storage do
  before do
    storage = Storage.new(name: "ExampleName", desc: "exampledesc", unit_id: 1)
  end

  it "is valid with a name" do
  	expect(storage).to be_valid
  end

  it "is invalid without a name" do
  	expect(Storage.new( name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a unit_id" do
  	expect(torage.new( unit_id: nil)).to have(1).errors_on(:unit_id)
  end
end
