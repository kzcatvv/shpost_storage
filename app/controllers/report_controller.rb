class ReportController < ApplicationController

  def purchase_arrival_report
    unless request.get?
      business_id = params[:business_id]
      start_date = Date.civil(params[:start_date]["start_date(1i)"].to_i,
                         params[:start_date]["start_date(2i)"].to_i,
                         params[:start_date]["start_date(3i)"].to_i)
      end_date = Date.civil(params[:end_date]["end_date(1i)"].to_i,
                         params[:end_date]["end_date(2i)"].to_i,
                         params[:end_date]["end_date(3i)"].to_i)
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

end
