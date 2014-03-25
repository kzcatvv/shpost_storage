require "spec_helper"

describe UserLogsController do
  describe "routing" do

    it "routes to #index" do
      get("/user_logs").should route_to("user_logs#index")
    end

    it "routes to #show" do
      get("/user_logs/1").should route_to("user_logs#show", id: "1")
    end
  end
end
