require 'spec_helper'

describe Role do
  before do
    @role = Role.new(user_id: 1, storage_id: 1, role: "sorter")
  end

  it "is valid with a user_id,storage_id,role" do
  	expect(@role).to be_valid
  end
end
