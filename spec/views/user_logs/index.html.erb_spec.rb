require 'spec_helper'

describe "user_logs/index" do
  before(:each) do
    assign(:user_logs, [
      stub_model(UserLog,
        :user_id => "User",
        :operation => "Operation",
        :object_class => "Object Class",
        :object_id => "Object"
      ),
      stub_model(UserLog,
        :user_id => "User",
        :operation => "Operation",
        :object_class => "Object Class",
        :object_id => "Object"
      )
    ])
  end

  it "renders a list of user_logs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => "Operation".to_s, :count => 2
    assert_select "tr>td", :text => "Object Class".to_s, :count => 2
    assert_select "tr>td", :text => "Object".to_s, :count => 2
  end
end
