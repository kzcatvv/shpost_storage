class GnxbSoap
  require "rexml/document"

  def order_query(uri, mehod)
    @interface_status = '0'
    begin
      client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
        
      # yjbhs = Order.where({status: [Order::STATUS[:delivering], Order::STATUS[:packed]], transport_type: "gnxb"}).map!{|x| x.tracking_number}
      orders = Order.where({status: [Order::STATUS[:delivering], Order::STATUS[:packed]], transport_type: "gnxb"})

      #yjbh = "9976613107785"
      #puts yjbhs

      orders.each do |order|
        yjbh = order.tracking_number
        puts "-------------" << yjbh << "-----------------"
        # response = client.call(mehod.to_sym, message: { in0: "6", in1: "192.168.0.1", in2: yjbh })
        # json = response.body["#{mehod}_response".to_sym]["out".to_sym]
        # gnxb_info = ""
        # gnxb_status = Order::STATUS[:packed]
        # if json.blank?
        #   next
        # end
        # json["mail".to_sym].each do |x|
        #   action_time = convertToString(x[:action_date_time],Date)
        #   office_desc = convertToString(x[:relation_office_desc],String)
        #   office_name = convertToString(x[:office_name],String)
        #   info_out = convertToString(x[:action_info_out],String)
        #   gnxb_info << action_time << "#" << office_desc << "#" << office_name << "#" << info_out << "\n"
        #   gnxb_status = returnStatus(info_out)
        # end
        gnxb_status = order.status
        params = {}
        params["mailNumber".to_sym] = yjbh
        res = gnxb_post(uri, params)
        if res.code.eql? '200'
          body = JSON.parse(res.body)
          code = body['code']
          data = body['data']
          mailTypeName = body['mailTypeName']
          mailNumber = body['mailNumber']

          if !code.eql? '-1'
            gnxb_info = ""

            data.each do |x|
              time = x[0]
              info = x[1]
              gnxb_info << time << "#" << info << "\n"
              gnxb_status = returnStatus(info)
            end
            updateOrder(yjbh,gnxb_info,gnxb_status)
          end
        end
        # sleep 5
      end
    rescue Exception => e
      puts e
      @interface_status = '1'
      #Rails.errors e.message
    ensure
      ActiveRecord::Base.connection_pool.release_connection
      # puts "#{@title} : #{@count}"
    end
  end

  private
  def self.test_mod?
    SalaryQueryConfig.config["test_mod"]
  end
  
  def convertToString(input,type)
    if input.is_a? type
      if type == Date
        return input.strftime("%Y-%m-%d %H:%M:%S")
      elsif type == String
        return input
      end
    else
      return ""
    end
  end

  def self.gnxb_post(uri,params)
    url = URI.parse(uri)
    res = Net::HTTP.post_form(uri, params)
    return res
  end
  
  def self.updateOrder(yjbh,tdxq,td_status)
    order = Order.find_by_tracking_number yjbh
    order.update status: td_status, tracking_info: tdxq
  end

  def self.setInBody()
    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
    doc = REXML::Document.new       #创建XML内容 
    getMails = doc.add_element('getMails')

    xml_file << doc.to_s
  end
  
  def returnStatus(tdxq)
    if !tdxq.blank?
      if tdxq.end_with? '已签收' || tdxq.end_with? '已妥投'
        return Order::STATUS[:delivered]
      end
    end
    return Order::STATUS[:delivering]
  end
end