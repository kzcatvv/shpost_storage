require 'spec_helper'

describe "storages/edit" do
  before(:each) do
    @storage = assign(:storage, stub_model(Storage,
      :name => "MyString",
      :desc => "MyString"
    ))
  end

  it "renders the edit storage form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", storage_path(@storage), "post" do
      assert_select "input#storage_name[name=?]", "storage[name]"
      assert_select "input#storage_desc[name=?]", "storage[desc]"
    end
  end
end
