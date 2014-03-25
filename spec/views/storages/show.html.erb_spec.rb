require 'spec_helper'

describe "storages/show" do
  before(:each) do
    @storage = assign(:storage, stub_model(Storage,
      :name => "Name",
      :desc => "Desc"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Desc/)
  end
end
