require 'spec_helper'

describe Specification do
  before do
    @specification = Specification.new(commodity_id: 1, model: "1111" , size: "16G", color: "red")
  end

  it "is valid with a user_id,storage_id,role" do
  	expect(@specification).to be_valid
  end
end
