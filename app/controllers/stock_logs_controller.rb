class StockLogsController < ApplicationController
  load_and_authorize_resource

  # GET /stock_logs
  # GET /stock_logs.json
  def index
    @stock_logs_grid = initialize_grid(@stock_logs)
  end

  # GET /stock_logs/1
  # GET /stock_logs/1.json
  def show
  end
end
