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
    desc "CSB Transmitter"
      task :update_order_status => :environment do
        generate_params 'transmitter.csb.update_order_status'

        while 1==1 do
          @count += 1
          begin
            orders = BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'waiting')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'printed')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'checked')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'picking')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'packed')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'delivering')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'delivered')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'declined')
            orders << BcmInterface.notice_array(StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'],'returned')
            return_array = CSBSendWithSOAP.updatePointOrderStatus(orders)
            if return_array[0]=="0"
              orders.each do |order|
                # todo: order:deliver_notice=1:N
                notice=order.deliver_notices[0]
                notice.status="success"
                notice.send_times=notice.send_times+1
                notice.save
              end
            else
              orders.each do |order|
                notice=order.deliver_notices[0]
                notice.status=return_array[0]+':'+return_array[1]
                notice.send_times=notice.send_times+1
                notice.save
              end
            end
          rescue Exception => e
            orders.each do |order|
              notice=order.deliver_notices[0]
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
