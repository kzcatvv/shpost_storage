class TcbdSoap
  
  def self.order_query(uri, mehod)
    client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
      
    yjbhs = Order.where({status: [Order::STATUS[:delivering], Order::STATUS[:packed]], transport_type: "tcsd"}).map!{|x| x.tracking_number}
    puts "yjbhs=" + yjbhs.to_s
    # yjbhs = ['PN00058784731', 'PN00058785531']
    if !yjbhs.blank?
      index = 0
      length = StorageConfig.config["tcsd"]['length']
      while index < yjbhs.size do
        yjbh_t = yjbhs[index, length]
        #puts "yjbh_t=" + yjbh_t.to_s
        response = client.call(mehod.to_sym, message: { yjbh: yjbh_t.to_s })
        #puts response
        #puts "================================="
        body = response.body["#{mehod}_response".to_sym]["#{mehod}_result".to_sym].to_s
        if body.start_with? '!'
          index = index + length
          next
        end
        json = JSON.parse body
        yjbh = ""
        tdxq = ""
        td_status = Order::STATUS[:packed]
        json["yjrzcx"].each do |x|
          if !yjbh.blank? and yjbh != x['yjbh']
            updateOrder(yjbh,tdxq,td_status)
            yjbh = x['yjbh']
            tdxq = ""
            td_status = ""
          elsif yjbh.blank?
            yjbh = x['yjbh']
          end
          tdxq << x['czsj'] << "#" << x['bgms'] << "\n"
          td_status = returnStatus(x['tdxq'])
        end
        updateOrder(yjbh,tdxq,td_status)
        index = index + length
      end
    end
  end

  private
  def self.test_mod?
    SalaryQueryConfig.config["test_mod"]
  end
  
  def self.updateOrder(yjbh,tdxq,td_status)
    order = Order.find_by_tracking_number yjbh
    if !order.blank?
      order.update status: td_status, tracking_info: tdxq
    end
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
