namespace :transmitter do
  namespace :bankcomm do
    desc "BankComm Transmitter"
      task :order_update => :environment do
        generate_params 'transmitter.bankcomm.order_update'

        while 1==1 do
          @count += 1
          plaintext=BcmInterfaceController.order_query.plaintext
          begin
            # body = your_class.your_def
            # body.format is a hash like {'plaintext' => '{[{prodId : '000001'}, {prodId : '000002'}]}', 'sign' => 's235$s1@kd9%ds6136', 'toalno' => '2'}
            # transmit_with_http(@uri, body)
            body = { 'format' => 'JSON', 'plaintext' => plaintext, 'totalno'=>BcmInterfaceController.order_query.totalno, 'sign'=>BcmInterfaceController.order_query.sign }
            bcm_return=transmit_with_http(@uri, body)
            bcm_return = ActiveSupport::JSON.decode(bcm_return)
            if bcm_return["returnFlag"]=="00"
              plaintext["goodsInfoS"].each do |g|
                order=Order.find_by(business_trans_no: g["transSn"]).id
                notice=DeliverNotice.where( :order_id => order, :send_type => g["deliverState"] )
                notice.status="success"
                notice.send_times=notice.send_times+1
                notice.save
              end
            else
              plaintext["goodsInfoS"].each do |g|
                order=Order.find_by(business_trans_no: g["transSn"]).id
                notice=DeliverNotice.where( :order_id => order, :send_type => g["deliverState"] )
                notice.status=bcm_return["returnCode"]
                notice.send_times=notice.send_times+1
                notice.save
              end
            end
          rescue Exception => e
            # puts e.message
            plaintext["goodsInfoS"].each do |g|
                order=Order.find_by(business_trans_no: g["transSn"]).id
                notice=DeliverNotice.where( :order_id => order, :send_type => g["deliverState"] )
                notice.status="HTTP Exception"
                notice.send_times=notice.send_times+1
                notice.save
              end
            Rails.errors e.message
          ensure
            ActiveRecord::Base.connection_pool.release_connection
            puts "#{@title} : #{@count}"
          end
        sleep @interval
      end
    end
  end

  namespace :csb do
    desc "CSB Transmitter update_order_status"
    task :update_order_status => :environment do
      generate_params 'transmitter.csb.update_order_status'

      while 1==1 do
        @count += 1
        orders = BcmInterface.csb_notice_array_all()
        begin
		  if orders.size == 0
		    next
		  end
          return_array = CSBSendWithSOAP.updatePointOrderStatus(orders)
		  puts return_array
          if return_array[0]=="0"
			puts 0
            orders.each do |order|
			  notice = DeliverNotice.where(order_id: order.id).last
              notice.status="success"
              notice.send_times=notice.send_times+1
              notice.save
            end
          else
			puts 1
            orders.each do |order|
			  notice = DeliverNotice.where(order_id: order.id).last
              notice.status=return_array[0]+':'+return_array[1]
              notice.send_times=notice.send_times+1
              notice.save
            end
          end
        rescue Exception => e
          puts "error:#{$!} at:#{$@}"
		  orders.each do |order|
		    notice = DeliverNotice.where(order_id: order.id).last
            notice.status="HTTP Exception"
            notice.send_times=notice.send_times+1
            notice.save
          end
          #Rails.errors e.message
        ensure
          ActiveRecord::Base.connection_pool.release_connection
          puts "#{@title} : #{@count}"
        end
        sleep @interval
      end
    end

    desc "CSB Transmitter order_status"
    task :order_status => :environment do
      generate_params 'transmitter.csb.order_status'

      while 1==1 do
        @count += 1
		orders = BcmInterface.csb_notice_array()
        begin
          return_array = CSBSendWithSOAP.pointOrderStatus(orders)
          if return_array[0]=="0"
            orders.each do |order|
              # todo: order:deliver_notice=1:N
			  notice = DeliverNotice.where(order_id: order.id).last
              notice.status="over"
              notice.send_times=notice.send_times+1
              notice.save
            end
          else
            orders.each do |order|
			  notice = DeliverNotice.where(order_id: order.id).last
              notice.status=return_array[0]+':'+return_array[1]
              notice.send_times=notice.send_times+1
              notice.save
            end
          end
        rescue Exception => e
		  puts "error:#{$!} at:#{$@}"
          orders.each do |order|
		    notice = DeliverNotice.where(order_id: order.id).last
            notice.status="HTTP Exception"
            notice.send_times=notice.send_times+1
            notice.save
          end
          Rails.errors e.message
        ensure
          ActiveRecord::Base.connection_pool.release_connection
          puts "#{@title} : #{@count}"
        end
        sleep @interval
      end
    end

    desc "CSB Transmitter send_point_order"
    task :send_point_order => :environment do
      generate_params 'transmitter.csb.send_point_order'

      while 1==1 do
        @count += 1
        begin
          return_array = CSBSendWithSOAP.sendPointOrder()
        rescue Exception => e
          #Rails.errors e.message
		  puts e.message
		  puts "error:#{$!} at:#{$@}"
        ensure
          ActiveRecord::Base.connection_pool.release_connection
          puts "#{@title} : #{@count}"
        end
		puts @interval
        sleep @interval
      end
    end
  end

  private
  def self.transmit_with_http(uri, body)
    @clnt ||= HTTPClient.new

    log_info ("post " + @title), body

    res = @clnt.post(uri, body)

    log_info ("return " + @title), body

    res.body
  end

  def self.generate_params(title)
    @title = title
    @interval = I18n.t "#{@title}.interval"
    @interval ||= 1800
    @uri = I18n.t "#{@title}.uri"
    @count = 0
  end

  def self.log_info(title, body)
    Rails.logger.info "********** #{Time.now.to_s} #{title}**********"
    Rails.logger.info body
    Rails.logger.info "****************************************************************************"
  end
end
