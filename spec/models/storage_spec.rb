require 'spec_helper'

describe Storage do
  before do
    @storage = Storage.new(name: "ExampleName", desc: "exampledesc", unit_id: 1)
  end

  it "is valid with a name" do
  	expect(@storage).to be_valid
  end

  
end
