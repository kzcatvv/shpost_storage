class GnxbSoap
  require "rexml/document"

  def self.order_query(uri, mehod)
    puts uri
    client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
      
    yjbh = Order.where({status: [Order::STATUS[:delivering], Order::STATUS[:packed]]}).map!{|x| x.tracking_number}.to_json
    puts yjbh
    yjbh = "PN00058784731"

    response = client.call(mehod.to_sym, message: { in0: "6", in1: "192.168.0.1", in2: yjbh })
    #in_body = setInBody()
    #puts in_body
    #response = gnxb_post(uri,in_body)
    body_s = response.body.to_s
    puts body_s
    doc = REXML::Document.new(body_s)
    root = doc.root
    head = root.elements['Mail']
    puts head
  end

  private
  def self.test_mod?
    SalaryQueryConfig.config["test_mod"]
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
      if tdxq.start_with? '已妥投'
		return Order::STATUS[:delivered]
      end
    end
	return Order::STATUS[:delivering]
  end
end