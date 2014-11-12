class TcbdSoap
  
  def order_query(uri, mehod)
    @interface_status = '0'
    begin
      client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
        
      yjbhs = Order.where({status: [Order::STATUS[:delivering], Order::STATUS[:packed]], transport_type: "tcsd"}).map!{|x| x.tracking_number}
      Rails.logger.info "yjbhs=" + yjbhs.to_s
      # yjbhs = ['PN00058784731', 'PN00058785531']
      if !yjbhs.blank?
        index = 0
        length = StorageConfig.config["tcsd"]["order_query"]['length']
        while index < yjbhs.size do
          yjbh_t = yjbhs[index, length]
          #Rails.logger.info "yjbh_t=" + yjbh_t.to_s
          response = client.call(mehod.to_sym, message: { yjbh: yjbh_t.to_s })
          #Rails.logger.info response
          #Rails.logger.info "================================="
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
            td_status = returnStatus(x['tdxq'],x['qrxq'])
          end
          updateOrder(yjbh,tdxq,td_status)
          index = index + length
        end
      end
    rescue Exception => e
      Rails.logger.error e
      @interface_status = '1'
      #Rails.errors e.message
    ensure
      ActiveRecord::Base.connection_pool.release_connection
      # puts "#{@title} : #{@count}"
    end
  end

  def order_enter(uri, mehod, keyclientorderid)
    @interface_status = '0'
    begin
      client = Savon.client(wsdl: uri, ssl_verify_mode: :none)
      keyclientorder = Keyclientorder.find keyclientorderid
      unit = keyclientorder.unit
      storage = keyclientorder.storage
      orders = keyclientorder.orders.where(transport_type: 'tcsd')
      # 邮件详情
      yjxq = {}
      yjxq_arr = []
      orders.each_with_index do |order,i|
        yjxq_hash = {}
        xh = i + 1
        yjbh = order.tracking_number
        njbh = " "
        sjrmc = setText(order.customer_name)
        sjrdz = setText(order.customer_address)
        sjrdw = setText(order.customer_unit)
        sjryb = setText(order.customer_postcode)
        pzyb = " "
        pzbk = " "
        pzcx = 0
        sjrdh = setText(order.customer_tel)
        sjrsj = setText(order.customer_phone)
        wpnr = ""
        wpjs = 0
        wpzl = 0
        chang = 0
        kuan = 0
        gao = 0
        order.order_details.each do |detail|
          wpnr << detail.name
          wpjs += detail.amount
          specification = detail.specification
          wpzl += setNum(specification.weight) * detail.amount
          chang = (chang >= setNum(specification.long)) ? chang : specification.long
          kuan = (kuan >= setNum(specification.wide) ) ? kuan : specification.wide
          gao = (gao >= setNum(specification.high) ) ? gao : specification.high
          
        end
        
        dtbz = 0
        dtrq = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
        je = 0
        gdje = 0
        bjje = 0
        dshkje = 0
        dshkjjbfb = 0
        dshejjje = 0
        hhbz = 0
        hdbz = 0
        tjdqbz = 0
        tybxbz = 0
        crlzbz = 0
        qttj = " "
        hkbz = "买家留言:" << setText(order.buyer_desc, "空") << "\n" << "卖家留言:" << setText(order.seller_desc, "空")
        xqdwjm = " "
        sjjhm = " "
        sjymz = " "

        yjxq_hash[:xh] = xh.to_s
        yjxq_hash[:yjbh] = yjbh
        yjxq_hash[:njbh] = njbh
        yjxq_hash[:sjrmc] = sjrmc.truncate(20)
        yjxq_hash[:sjrdz] = sjrdz.truncate(100)
        yjxq_hash[:sjrdw] = sjrdw.truncate(100)
        yjxq_hash[:sjryb] = sjryb
        yjxq_hash[:pzyb] = pzyb
        yjxq_hash[:pzbk] = pzbk
        yjxq_hash[:pzcx] = pzcx.to_s
        yjxq_hash[:sjrdh] = sjrdh
        yjxq_hash[:sjrsj] = sjrsj
        yjxq_hash[:wpnr] = wpnr.truncate(100)
        yjxq_hash[:wpjs] = wpjs.to_s
        yjxq_hash[:wpzl] = (wpzl/1000).round(1).to_s
        yjxq_hash[:chang] = chang.round(1).to_s
        yjxq_hash[:kuan] = kuan.round(1).to_s
        yjxq_hash[:gao] = gao.round(1).to_s
        yjxq_hash[:dtbz] = dtbz.to_s
        yjxq_hash[:dtrq] = dtrq
        yjxq_hash[:je] = je.to_s
        yjxq_hash[:gdje] = gdje.to_s
        yjxq_hash[:bjje] = bjje.to_s
        yjxq_hash[:dshkje] = dshkje.to_s
        yjxq_hash[:dshkjjbfb] = dshkjjbfb.to_s
        yjxq_hash[:dshejjje] = dshejjje.to_s
        yjxq_hash[:hhbz] = hhbz.to_s
        yjxq_hash[:hdbz] = hdbz.to_s
        yjxq_hash[:tjdqbz] = tjdqbz.to_s
        yjxq_hash[:tybxbz] = tybxbz.to_s
        yjxq_hash[:crlzbz] = crlzbz.to_s
        yjxq_hash[:qttj] = qttj
        yjxq_hash[:hkbz] = hkbz.truncate(255)
        yjxq_hash[:xqdwjm] = xqdwjm
        yjxq_hash[:sjjhm] = sjjhm
        yjxq_hash[:sjymz] = sjymz
        yjxq_arr[i] = yjxq_hash
      end

      # 邮件详情
      yjxq[:yjxq] = yjxq_arr
      # 客户代号
      khdh = 337
      # khdh = setNum(unit.tcbd_khdh)
      # 产品代号
      cpdh = 11
      # cpdh = setNum(storage.tcbd_product_no)
      # 寄件人姓名 (仓库的代号或名称)
      jjrxm = setText(storage.name).truncate(20)
      # 寄件人地址
      jjrdz = setText(storage.address).truncate(100)
      # 寄件人电话 (仓库客服电话)
      jjrdh = setText(storage.phone).truncate(30)
      # 寄件人单位
      jjrdw = setText(unit.name).truncate(100)
      # 寄件人邮编 (按照邮编判收寄局)
      jjryb = '200999'
      # jjryb = setText(storage.postcode)

      Rails.logger.info "yjxq=" + yjxq.to_json
      response = client.call(mehod.to_sym, message: { yjxq: yjxq.to_json, khdh: khdh, cpdh: cpdh, jjrxm: jjrxm, jjrdz: jjrdz, jjrdh: jjrdh, jjrdw: jjrdw, jjryb: jjryb })
      Rails.logger.info response
      Rails.logger.info "================================="
      body = response.body["#{mehod}_response".to_sym]["#{mehod}_result".to_sym].to_s
      json = JSON.parse body
      jjpch = json["pdjg"][0]["jjpch"].to_i
      pdjg = json["pdjg"][0]["pdjg"]
      return [jjpch,pdjg]

    rescue Exception => e
      Rails.logger.error e.backtrace
      @interface_status = '1'
      return [-999,e.message]
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
  
  def updateOrder(yjbh,tdxq,td_status)
    order = Order.find_by_tracking_number yjbh
    if !order.blank?
      order.update status: td_status, tracking_info: tdxq
    end
  end
  
  def returnStatus(tdxq,qrxq)
    if !tdxq.blank?
      if tdxq.start_with? '已妥投'
        return Order::STATUS[:delivered]
      end
    end
    if !qrxq.blank?
      if qrxq.start_with? '确认退件'
        return Order::STATUS[:returned]
      end
    end
    return Order::STATUS[:delivering]
  end

  def setText(str, default=" ")
    if str.blank?
      return default
    else
      return str
    end
  end

  def setNum(num)
    if num.blank?
      return 0
    else
      return num
    end
  end
end
