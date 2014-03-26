require 'spec_helper'

describe "user_logs/show" do
  before(:each) do
    @user_log = assign(:user_log, stub_model(UserLog,
      :user_id => "User",
      :operation => "Operation",
      :object_class => "Object Class",
      :object_id => "Object"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/User/)
    rendered.should match(/Operation/)
    rendered.should match(/Object Class/)
    rendered.should match(/Object/)
  end
end
