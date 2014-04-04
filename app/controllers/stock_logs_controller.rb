class StockLogsController < ApplicationController
  before_filter :find_current_storage
  load_and_authorize_resource

  # GET /stock_logs
  # GET /stock_logs.json
  def index
    @stock_logs_grid = initialize_grid(@stock_logs, include: :user)
  end

  # GET /stock_logs/1
  # GET /stock_logs/1.json
  def show
  end

  def find_current_storage
    @areas = Area.where("storage_id = ?", session[:current_storage].id)
    @shelves = Shelf.where("area_id in (?)", @areas.ids)
  end

  def stockindex
    @stock_logs_grid = initialize_grid(@stock_logs, include: [:user,:stock])
  end

  def check
    params[:stock_logs].each do |stock_log|
      @stock_log = StockLog.find(stock_log[:id])
      @stock = @stock_log.stock
      @stock.shelf_id = stock_log[:shelf_id]
      
      @stock_log.status = stock_log[:status]
      @stock_log.amount = stock_log[:amount]

      puts "-----------------------------------"
      puts @stock_log
      puts @stock
      puts "-----------------------------------"

      @stock.save!()
      @stock_log.save!()
      # order_info = SubOrder.new info
      # if order_info.product_number.is_a?(Integer) and order_info.product_number > 0
      #   @sendtext << order_info.product.name
      #   @sendtext << order_info.product_number.to_s
      #   @sendtext << "份 "
      #   params[:order][:sub_orders] << order_info
      # end
    end
    redirect_to request.referer
  end
end
