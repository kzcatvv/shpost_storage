class UserLogsController < ApplicationController
 load_and_authorize_resource

  # GET /user_logs
  # GET /user_logs.json
  def index
    @user_logs_grid = initialize_grid(@user_logs)
  end

  # GET /user_logs/1
  # GET /user_logs/1.json
  def show
  end

end
