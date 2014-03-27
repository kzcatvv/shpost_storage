require 'spec_helper'

describe Unit do
  before do
    @unit = Unit.new(name: "ExampleName", desc: "exampledesc")
  end

  it "is valid with a name" do
  	expect(@unit).to be_valid
  end

  

end
