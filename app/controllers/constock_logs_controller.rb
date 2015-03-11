class ConstockLogsController < ApplicationController
	load_and_authorize_resource

  def index
    @constock_logs_grid = initialize_grid(@constock_logs, 
      order: "constock_logs.id",
      order_direction: 'desc')
  end

  def show
  end
  
end
