class ReportController < ApplicationController
  
  def purchase_arrival_report
    unless request.get?
      business_id = params[:business_id]
      start_date = Date.civil(params[:start_date]["start_date"].split(/-|\//)[0].to_i,
                         params[:start_date]["start_date"].split(/-|\//)[1].to_i,
                         params[:start_date]["start_date"].split(/-|\//)[2].to_i)
      end_date = Date.civil(params[:end_date]["end_date"].split(/-|\//)[0].to_i,
                         params[:end_date]["end_date"].split(/-|\//)[1].to_i,
                         params[:end_date]["end_date"].split(/-|\//)[2].to_i)
      if business_id.blank?
        flash[:alert] = "请选择一个商户"
        redirect_to :action => 'purchase_arrival_report'
      else
        Rails.logger.info "business_id:" + business_id.to_s
        Rails.logger.info "start_date:" + start_date.to_s
        Rails.logger.info "end_date:" + end_date.to_s
        purchases=Purchase.accessible_by(current_ability).where(business_id: business_id).where("created_at >= ? and created_at <= ?", start_date, (end_date+1))
        if purchases.blank?
          flash[:alert] = "无补货数据"
          redirect_to :action => 'purchase_arrival_report'
        else
          # respond_to do |format|  
          #   format.xls {   
              send_data(purchase_arrival_report_xls_content_for(purchases),  
                    :type => "text/excel;charset=utf-8; header=present",  
                    :filename => "补货订单汇总_#{Time.now.strftime("%Y%m%d")}.xls")  
          #   }  
          # end
        end
      end
    end
  end

  def purchase_arrival_report_xls_content_for(objs)  
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => "补货订单汇总"  
    
      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  
  
      sheet1.row(0).concat %w{采购单编号 商户名称 SKU 商品编码 供应商名称 商品名称 补货数量 到货日 采购单日期 实际到货}
      count_row = 1
      objs.each do |obj|
        previous_detail_id = nil
        obj.purchase_details.each do |detail|
          relationship = Relationship.find_by(specification: detail.specification, business: detail.purchase.business, supplier: detail.supplier)
          if detail.purchase_arrivals.blank?
            sheet1[count_row,0] = detail.purchase.no
            sheet1[count_row,1] = detail.purchase.business.name
            sheet1[count_row,2] = detail.specification.sku
            sheet1[count_row,3] = relationship.blank? ? "" : relationship.external_code
            sheet1[count_row,4] = detail.supplier.name
            sheet1[count_row,5] = detail.specification.name
            sheet1[count_row,6] = detail.amount
            sheet1[count_row,8] = detail.purchase.created_at.to_date.to_s

            sheet1[count_row,7] = ""
            sheet1[count_row,9] = "没货"

            previous_detail_id = detail.id
            count_row += 1
          else
            detail.purchase_arrivals.each do |arrival|
              if previous_detail_id == detail.id
                sheet1[count_row,0] = ""
                sheet1[count_row,1] = ""
                sheet1[count_row,2] = ""
                sheet1[count_row,3] = ""
                sheet1[count_row,4] = ""
                sheet1[count_row,5] = ""
                sheet1[count_row,6] = ""
                sheet1[count_row,8] = ""
              else
                sheet1[count_row,0] = detail.purchase.no
                sheet1[count_row,1] = detail.purchase.business.name
                sheet1[count_row,2] = detail.specification.sku
                sheet1[count_row,3] = relationship.blank? ? "" : relationship.external_code
                sheet1[count_row,4] = detail.supplier.name
                sheet1[count_row,5] = detail.specification.name
                sheet1[count_row,6] = detail.amount
                sheet1[count_row,8] = detail.purchase.created_at.to_date.to_s

                previous_detail_id = detail.id
              end
              sheet1[count_row,7] = arrival.arrived_at
              sheet1[count_row,9] = arrival.arrived_amount

              count_row += 1
            end
          end
        end

      end  
  
      book.write xls_report  
      xls_report.string  
    end


  def stock_stat_report
   unless request.get?
    if params[:stock]["summ_date(1i)".to_sym].blank?
      flash[:alert] = "请选择年份"
      redirect_to :back
    elsif params[:stock]["summ_date(2i)".to_sym].blank?
      flash[:alert] = "请选择月份"
      redirect_to :back
    elsif params[:stock][:business_id] == "请选择"
      flash[:alert] = "请选择商户"
      redirect_to :back
    elsif params[:return_in].nil? && params[:purchase_in].nil? && params[:bad_in].nil? && params[:bad_return].nil?
      flash[:alert] = "请选择入库口径"
      redirect_to :back
    elsif params[:b2c_out].nil? && params[:b2b_out].nil? && params[:move_bad].nil?
      flash[:alert] = "请选择出库口径"
      redirect_to :back
    else
      @business = Business.find(params[:stock][:business_id])
      year = params[:stock]["summ_date(1i)".to_sym].to_s
      month = params[:stock]["summ_date(2i)".to_sym].to_s
      op_type_in = []
      op_type_out = []
      if !params[:return_in].nil?
        op_type_in.push(params[:return_in])
      end

      if !params[:purchase_in].nil?
        op_type_in.push(params[:purchase_in])
      end

      if !params[:bad_in].nil?
        op_type_in.push(params[:return_in])
      end

      if !params[:bad_return].nil?
        op_type_in.push(params[:bad_return])
      end

      if !params[:b2c_out].nil?
        op_type_out.push(params[:b2c_out])
      end

      if !params[:b2b_out].nil?
        op_type_out.push(params[:b2b_out])
      end

      if !params[:move_bad].nil?
        op_type_out.push(params[:move_bad])
      end

      stock_hash = Stock.includes(:storage).where("storages.id = ?",current_storage.id).group(:business_id,:supplier_id,:specification_id).sum(:actual_amount)

      # respond_to do |format|
      #   format.xls {   
          send_data(stock_stat_content_for(stock_hash,@business.id,year,month,op_type_in,op_type_out),  
            :type => "text/excel;charset=utf-8; header=present",  
            :filename => "#{year}年#{month}月库存状态表.xls")  
        # }
      # end

    end
   end
    # binding.pry
  end

  def stock_stat_content_for(hashs,business_id,year,month,op_in_type,op_out_type)
      xls_report = StringIO.new  
      book = Spreadsheet::Workbook.new  
      sheet1 = book.create_worksheet :name => year+"年"+month+"月"

      blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
      sheet1.row(0).default_format = blue  

      summ_start_dt = Date.new(Integer(year),Integer(month))
      summ_end_dt = summ_start_dt + 1.month - 1
      summ_last_month = (summ_start_dt-1.month).strftime("%Y%m")
      monthdays = Integer(summ_end_dt - summ_start_dt + 1)

      cnt_dt = []

      (summ_start_dt .. summ_end_dt).each do |date|
        cnt_dt.push(date.strftime("%Y%m%d"))
      end

      sheet1.row(0).concat %w{序号 产品编号 供应商名称 商品名称 上月结存数 实时库存 日均兑换量 月均兑换量 是否补货}
      sheet1.row(0).concat cnt_dt
      sheet1.row(0).concat %w{备用 合计数}
      sheet1.row(0).concat cnt_dt
      sheet1.row(0).concat %w{本月入库}
      sheet1[1,0]="合计"
      count_row = 2
      sp_no = 1
      col_num = 9
      row1_col_num = 9 
      out_hash_sum = 0
      in_hash_sum = 0

      # fix bug for sql error(to_char in Oracle and strftime in sqlite3)
      whereQuery = ""
      if RailsEnv.is_oracle?
        whereQuery = "storages.id=? and stock_logs.business_id = ? and stock_logs.operation in (?) and to_char(stock_logs.created_at,'yyyymm')=?"
      else
        whereQuery = "storages.id=? and stock_logs.business_id = ? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?"
      end
      sllos=StockLog.includes(:storage).where(whereQuery,current_storage.id,business_id,op_out_type, ( month.to_s.length == 1 ? year.to_s+"0"+month.to_s : year.to_s+month.to_s)).to_ary
      whereQuery = ""
      if RailsEnv.is_oracle?
        whereQuery = "to_char(created_at,'yyyymmdd')"
      else
        whereQuery = "strftime('%Y%m%d',created_at)"
      end
      stock_out_all_summdt_hash = StockLog.where(id: sllos).group(whereQuery).sum(:amount)
      
      (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[1,row1_col_num]= stock_out_all_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_out_all_summdt_hash[date.strftime("%Y%m%d")]
          row1_col_num += 1
      end
      row1_col_num = row1_col_num + 2
      whereQuery = ""
      if RailsEnv.is_oracle?
        whereQuery = "storages.id=? and stock_logs.business_id = ? and stock_logs.operation in (?) and to_char(stock_logs.created_at,'yyyymm')=?"
      else
        whereQuery = "storages.id=? and stock_logs.business_id = ? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?"
      end
      sllis=StockLog.includes(:storage).where(whereQuery,current_storage.id,business_id,op_in_type, ( month.to_s.length == 1 ? year.to_s+"0"+month.to_s : year.to_s+month.to_s)).to_ary
      if RailsEnv.is_oracle?
        whereQuery = "to_char(created_at,'yyyymmdd')"
      else
        whereQuery = "strftime('%Y%m%d',created_at)"
      end
      stock_in_all_summdt_hash = StockLog.where(id: sllis).group(whereQuery).sum(:amount)
      
      (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[1,row1_col_num]= stock_in_all_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_in_all_summdt_hash[date.strftime("%Y%m%d")]
          row1_col_num += 1
      end


      hashs.each do |key,value| 
        sheet1[count_row,0]=sp_no.to_s
        sheet1[count_row,1]=Specification.find(key[2]).sku.to_s
        sheet1[count_row,2]=Supplier.find(key[1]).name.to_s
        sheet1[count_row,3]=Specification.find(key[2]).all_name.to_s
        sheet1[count_row,4]=StockMon.where("summ_date = ? and storage_id = ? and business_id = ? and supplier_id = ? and specification_id = ?",summ_last_month,current_storage.id,key[0],key[1],key[2]).blank? ? 0 : StockMon.where("summ_date = ? and storage_id = ? and business_id = ? and supplier_id = ? and specification_id = ?",summ_last_month,current_storage.id,key[0],key[1],key[2]).first.amount
        sheet1[count_row,5]=value

        whereQuery = ''
        if RailsEnv.is_oracle?
          whereQuery = "storages.id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and stock_logs.specification_id=? and stock_logs.operation in (?) and to_char(stock_logs.created_at,'yyyymm')=?"
        else
          whereQuery = "storages.id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and stock_logs.specification_id=? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?"
        end
        slos=StockLog.includes(:storage).where(whereQuery,current_storage.id,key[0],key[1],key[2],op_out_type,( month.to_s.length == 1 ? year.to_s+"0"+month.to_s : year.to_s+month.to_s)).to_ary
        whereQuery = ''
        if RailsEnv.is_oracle?
          whereQuery = "to_char(created_at,'yyyymmdd')"
        else
          whereQuery = "strftime('%Y%m%d',created_at)"
        end
        stock_out_summdt_hash = StockLog.where(id: slos).group(whereQuery).sum(:amount)
        if !stock_out_summdt_hash.nil?
          stock_out_summdt_hash.each do |key,value|
            out_hash_sum += value
          end
        end

        (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[count_row,col_num]= stock_out_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_out_summdt_hash[date.strftime("%Y%m%d")]
          col_num += 1
        end

        col_num = col_num + 1
        sheet1[count_row,6]=out_hash_sum/monthdays
        sheet1[count_row,7]=out_hash_sum
        sheet1[count_row,col_num]=out_hash_sum
        col_num = col_num + 1

        whereQuery = ''
        if RailsEnv.is_oracle?
          whereQuery = "storages.id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and stock_logs.specification_id=? and stock_logs.operation in (?) and to_char(stock_logs.created_at,'yyyymm')=?"
        else
          whereQuery = "storages.id=? and stock_logs.business_id=? and stock_logs.supplier_id=? and stock_logs.specification_id=? and stock_logs.operation in (?) and strftime('%Y%m',stock_logs.created_at)=?"
        end
        slis=StockLog.includes(:storage).where(whereQuery,current_storage.id,key[0],key[1],key[2],op_in_type,( month.to_s.length == 1 ? year.to_s+"0"+month.to_s : year.to_s+month.to_s)).to_ary
        whereQuery = ''
        if RailsEnv.is_oracle?
          whereQuery = "to_char(created_at,'yyyymmdd')"
        else
          whereQuery = "strftime('%Y%m%d',created_at)"
        end
        stock_in_summdt_hash = StockLog.where(id: slis).group(whereQuery).sum(:amount)
        if !stock_in_summdt_hash.nil?
          stock_in_summdt_hash.each do |key,value|
            in_hash_sum += value
          end
        end

        (summ_start_dt .. summ_end_dt).each do |date|
          sheet1[count_row,col_num]= stock_in_summdt_hash[date.strftime("%Y%m%d")].nil? ? 0 : stock_in_summdt_hash[date.strftime("%Y%m%d")]
          col_num += 1
        end
        sheet1[count_row,col_num]=in_hash_sum

        count_row += 1
        sp_no += 1
        col_num = 9 
        out_hash_sum = 0
        in_hash_sum = 0
      end

      book.write xls_report  
      xls_report.string  
    end

  def order_report
    unless request.get?
      if params[:order_start_date].blank? or params[:order_start_date]["order_start_date"].blank?
        start_date=to_date(DateTime.parse(Time.now.beginning_of_week.to_s).strftime('%Y-%m-%d').to_s)
        
      else
        start_date = to_date(params[:order_start_date]["order_start_date"])
      end
      if params[:order_end_date].blank? or params[:order_end_date]["order_end_date"].blank?
        end_date=to_date(DateTime.parse(Time.now.end_of_week.to_s).strftime('%Y-%m-%d').to_s)
      else
        end_date =to_date(params[:order_end_date]["order_end_date"])
      end
      status = ["waiting","checked","packed","delivering","delivered","returned"]

      orders=Order.accessible_by(current_ability).where("orders.created_at >= ? and orders.created_at <= ? and orders.status in (?)", start_date, (end_date+1),status)
      if orders.blank?
        flash[:alert] = "无订单数据"
        redirect_to :action => 'order_report'
      else
        send_data(order_report_xls_content_for(orders),:type => "text/excel;charset=utf-8; header=present",:filename => "订单汇总_#{Time.now.strftime("%Y%m%d")}.xls")  
      end
    end
  end
  
  def order_report_xls_content_for(objs) 
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "订单汇总"  
    
    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  
  
    sheet1.row(0).concat %w{商户 物流供应商 待处理 已审核 已包装 正在寄送中 已寄达 退回 总计}
    count_row = 1
    businesses = objs.select(:business_id).distinct.order(:business_id)
    tran_types = objs.select(:transport_type).distinct.order(:transport_type)
          
    businesses.each do |b|
      if !b.business_id.blank?
        bamount = objs.where(business_id:b.business_id).count
        if bamount>0
          sheet1[count_row,0] = Business.find_by(id:b.business_id).name
          tran_types.each do |t|
            # if !t.transport_type.blank?
              tamount = objs.where(business_id:b.business_id,transport_type:t.transport_type).count
              if tamount>0
                sheet1[count_row,1] = t.transport_type_name
                sheet1[count_row,2] = objs.where(business_id:b.business_id,transport_type:t.transport_type,status:"waiting").count
                sheet1[count_row,3] = objs.where(business_id:b.business_id,transport_type:t.transport_type,status:"checked").count
                sheet1[count_row,4] = objs.where(business_id:b.business_id,transport_type:t.transport_type,status:"packed").count
                sheet1[count_row,5] = objs.where(business_id:b.business_id,transport_type:t.transport_type,status:"delivering").count
                sheet1[count_row,6] = objs.where(business_id:b.business_id,transport_type:t.transport_type,status:"delivered").count
                sheet1[count_row,7] = objs.where(business_id:b.business_id,transport_type:t.transport_type,status:"returned").count
                sheet1[count_row,8] = tamount
                count_row += 1
              end
            # end
          end
        end
      end
    end
    sheet1[count_row,0] = "总计"
    sheet1[count_row,2] = objs.where(status:"waiting").count
    sheet1[count_row,3] = objs.where(status:"checked").count
    sheet1[count_row,4] = objs.where(status:"packed").count
    sheet1[count_row,5] = objs.where(status:"delivering").count
    sheet1[count_row,6] = objs.where(status:"delivered").count
    sheet1[count_row,7] = objs.where(status:"returned").count
    sheet1[count_row,8] = objs.count

    book.write xls_report  
    xls_report.string
  end
                
  private
  def to_date(time)
    date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
    return date
  end


end
