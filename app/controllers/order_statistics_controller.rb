class OrderStatisticsController < ApplicationController
  skip_before_filter :authenticate_user!
  

  def query_order_report
    @order_hash = {}
    @orders = Order.all
    @start_date=DateTime
    @end_date=DateTime
    if !current_user.blank?
      authorize! :query_order_report, :orders
    end
    
    status = ["waiting","checked","packed","printed","picking","delivering","delivered","returned"]
    
    if params[:query_order_start_date].blank? or params[:query_order_start_date]["query_order_start_date"].blank?
      @start_date=to_date(DateTime.parse(Time.now.beginning_of_week.to_s).strftime('%Y-%m-%d').to_s)
    else 
      @start_date = to_date(params[:query_order_start_date]["query_order_start_date"])
    end

    if params[:query_order_end_date].blank? or params[:query_order_end_date]["query_order_end_date"].blank?
      @end_date=to_date(DateTime.parse(Time.now.end_of_week.to_s).strftime('%Y-%m-%d').to_s)
    else
      @end_date = to_date(params[:query_order_end_date]["query_order_end_date"])
    end

    if current_user.blank?
        @orders=@orders.where("orders.created_at >= ? and orders.created_at<= ? and orders.status in (?)", @start_date,(@end_date+1),status)
    else
      @orders=@orders.where("orders.created_at >= ? and orders.created_at<= ? and orders.status in (?) and orders.unit_id = ?", @start_date,(@end_date+1),status,current_user.unit_id)
    end
    
    @order_hash = @orders.group(:storage_id).group(:business_id).group(:transport_type).order(:storage_id).order(:business_id).order(:transport_type).count


  end

  def order_statistic_details
    if !current_user.blank?
      authorize! :order_statistic_details, :orders
    end
    
    @orders = []
    start_date = to_date(params[:start_date])
    end_date = to_date(params[:end_date])
    storage_id = params[:key0].blank?? nil:params[:key0]
    business_id = params[:key1].blank?? nil:params[:key1]
    transport_type = params[:key2].blank?? nil:params[:key2]

    @orders=Order.where("orders.created_at >= ? and orders.created_at<= ?", start_date,(end_date+1)).where(storage_id:storage_id,business_id:business_id,transport_type:transport_type)
    
    if !current_user.blank?
      @orders=@orders.where("orders.unit_id = ?", current_user.unit_id)
    end
  end

  private
  def to_date(time)
    date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
    return date
  end

end
