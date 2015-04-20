class OrderStatisticsController < ApplicationController
  skip_before_filter :authenticate_user!
  

  def query_order_report
    @order_hash = {}
    @orders = Order.all
    if !current_user.blank?
      authorize! :query_order_report, :orders
    end
    
    status = ["waiting","checked","packed","delivering","delivered","returned"]
    
    if params[:query_order_start_date].blank? or params[:query_order_start_date]["query_order_start_date"].blank?
      start_date = Time.now.beginning_of_week
      if RailsEnv.is_oracle?
        start_date = to_char(DateTime.parse(start_date.to_s),'yyyymmdd')
      else
        start_date=DateTime.parse(start_date.to_s).strftime('%Y-%m-%d').to_s
      end
      if current_user.blank?
        @orders=@orders.where("orders.created_at >= ? and orders.status in (?)", start_date,status)
      else
        @orders=@orders.where("orders.created_at >= ? and orders.status in (?) and orders.unit_id = ?", start_date,status,current_user.unit_id)
      end
    else 
      start_date = Date.civil(params[:query_order_start_date]["query_order_start_date"].split(/-|\//)[0].to_i, params[:query_order_start_date]["query_order_start_date"].split(/-|\//)[1].to_i, params[:query_order_start_date]["query_order_start_date"].split(/-|\//)[2].to_i)
      if current_user.blank?
        @orders=@orders.where("orders.created_at >= ? and orders.status in (?)", start_date,status)
      else
        @orders=@orders.where("orders.created_at >= ? and orders.status in (?) and orders.unit_id = ?", start_date,status,current_user.unit_id)
      end
    end
    if params[:query_order_end_date].blank? or params[:query_order_end_date]["query_order_end_date"].blank?
      end_date = Time.now.end_of_week
      if RailsEnv.is_oracle?
        end_date = to_char(DateTime.parse(end_date.to_s),'yyyymmdd')
      else
        end_date=DateTime.parse(end_date.to_s).strftime('%Y-%m-%d').to_s
      end
      end_date = Date.civil(end_date.split(/-|\//)[0].to_i, end_date.split(/-|\//)[1].to_i, end_date.split(/-|\//)[2].to_i)
      if current_user.blank?
        @orders=@orders.where("orders.created_at <= ? and orders.status in (?)", (end_date+1),status)
      else
        @orders=@orders.where("orders.created_at >= ? and orders.status in (?) and orders.unit_id = ?", start_date,status,current_user.unit_id)
      end
    else
      end_date = Date.civil(params[:query_order_end_date]["query_order_end_date"].split(/-|\//)[0].to_i, params[:query_order_end_date]["query_order_end_date"].split(/-|\//)[1].to_i, params[:query_order_end_date]["query_order_end_date"].split(/-|\//)[2].to_i)
      if current_user.blank?
        @orders=@orders.where("orders.created_at <= ? and orders.status in (?)", (end_date+1),status)
      else
        @orders=@orders.where("orders.created_at >= ? and orders.status in (?) and orders.unit_id = ?", start_date,status,current_user.unit_id)
      end

    end
    
    @order_hash = @orders.group(:business_id).group(:transport_type).order(:business_id).order(:transport_type).count


  end


end
