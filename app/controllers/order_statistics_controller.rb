class OrderStatisticsController < ApplicationController
  skip_before_filter :authenticate_user!
  

  def query_order_report
    @order_hash = {}
    @orders = Order.all
    start_date=DateTime
    end_date=DateTime
    if !current_user.blank?
      authorize! :query_order_report, :orders
    end
    
    status = ["waiting","checked","packed","delivering","delivered","returned"]
    
    if params[:query_order_start_date].blank? or params[:query_order_start_date]["query_order_start_date"].blank?
      start_date=to_date(DateTime.parse(Time.now.beginning_of_week.to_s).strftime('%Y-%m-%d').to_s)
    else 
      start_date = to_date(params[:query_order_start_date]["query_order_start_date"])
    end

    if params[:query_order_end_date].blank? or params[:query_order_end_date]["query_order_end_date"].blank?
      end_date=to_date(DateTime.parse(Time.now.end_of_week.to_s).strftime('%Y-%m-%d').to_s)
    else
      end_date = to_date(params[:query_order_end_date]["query_order_end_date"])
    end

    if current_user.blank?
        @orders=@orders.where("orders.created_at >= ? and orders.created_at<= ? and orders.status in (?)", start_date,(end_date+1),status)
    else
      @orders=@orders.where("orders.created_at >= ? and orders.created_at<= ? and orders.status in (?) and orders.unit_id = ?", start_date,(end_date+1),status,current_user.unit_id)
    end
    
    @order_hash = @orders.group(:business_id).group(:transport_type).order(:business_id).order(:transport_type).count


  end

  private
  def to_date(time)
    date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
    return date
  end

end
