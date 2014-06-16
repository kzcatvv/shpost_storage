class TcbdSoap
  
  def self.order_query(uri, mehod)
    client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
      
    yjbh = Order.where({status: Order::STATUS[:delivering]}).map!{|x| x.tracking_number}.to_json

    # yjbh = "['PN00058784731', 'PN00058785531']"

    response = client.call(mehod.to_sym, message: { yjbh: yjbh })

    body = response.body["#{mehod}_response".to_sym][:return].to_s

    json = JSON.parse body

    json.each do |x|
      if !x['tdjgxq'].bank?
        if x['tdjgxq'].start_with? '妥投'
          order = Order.find_by_tracking_number x['yjbh']
          order.update status: Order::STATUS[:delivered]
        end
      end
    end
  end



  private
  def self.test_mod?
    SalaryQueryConfig.config["test_mod"]
  end
end