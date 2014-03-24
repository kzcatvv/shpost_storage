require 'spec_helper'

describe "user_logs/new" do
  before(:each) do
    assign(:user_log, stub_model(UserLog,
      :user_id => "MyString",
      :operation => "MyString",
      :object_class => "MyString",
      :object_id => "MyString"
    ).as_new_record)
  end

  it "renders new user_log form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_logs_path, "post" do
      assert_select "input#user_log_user_id[name=?]", "user_log[user_id]"
      assert_select "input#user_log_operation[name=?]", "user_log[operation]"
      assert_select "input#user_log_object_class[name=?]", "user_log[object_class]"
      assert_select "input#user_log_object_id[name=?]", "user_log[object_id]"
    end
  end
end
