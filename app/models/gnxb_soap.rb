class GnxbSoap
  require "rexml/document"

  def self.order_query(uri, mehod)

    client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
      
    yjbhs = Order.where({status: [Order::STATUS[:delivering], Order::STATUS[:packed]], transport_type: "gnxb"}).map!{|x| x.tracking_number}

    #yjbh = "9900162517212"
    #puts yjbhs
	
	yjbhs.each do |yjbh|
	  puts "-------------" << yjbh << "-----------------"
		response = client.call(mehod.to_sym, message: { in0: "6", in1: "192.168.0.1", in2: yjbh })
		json = response.body["#{mehod}_response".to_sym]["out".to_sym]
		gnxb_info = ""
		gnxb_status = Order::STATUS[:packed]
		if json.blank?
		  next
		end
		json["mail".to_sym].each do |x|
		  action_time = convertToString(x[:action_date_time],Date)
		  office_desc = convertToString(x[:relation_office_desc],String)
		  office_name = convertToString(x[:office_name],String)
		  info_out = convertToString(x[:action_info_out],String)
		  gnxb_info << action_time << "#" << office_desc << "#" << office_name << "#" << info_out << "\n"
		  gnxb_status = returnStatus(info_out)
		end
		updateOrder(yjbh,gnxb_info,gnxb_status)
    sleep 5
	end
  end

  private
  def self.test_mod?
    SalaryQueryConfig.config["test_mod"]
  end
  
  def self.convertToString(input,type)
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

  def self.gnxb_post(uri,body)
    url = URI.parse(uri)
    request = Net::HTTP::Post.new(url.path)
    request.content_type = 'text/xml'
    request.body = body
    response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
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
  
  def self.returnStatus(tdxq)
	if !tdxq.blank?
      if tdxq.start_with? '已签收'
		return Order::STATUS[:delivered]
      end
    end
	return Order::STATUS[:delivering]
  end
end