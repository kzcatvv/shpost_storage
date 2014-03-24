require "spec_helper"

describe UserLogsController do
  describe "routing" do

    it "routes to #index" do
      get("/user_logs").should route_to("user_logs#index")
    end

    it "routes to #new" do
      get("/user_logs/new").should route_to("user_logs#new")
    end
  end
end
