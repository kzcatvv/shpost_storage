class CSBSendWithSOAP
  require "rexml/document"

  @@call_flg = false
  # @@startrow = 1

  def self.sendPointOrder()
    # @count += 1
    begin
      for order_type in 1..2
        # puts order_type
        @@call_flg = false
        begin 
          xml_file = setSendPointOrder(order_type)
          # puts '------------start----------------'
          # puts xml_file
          # puts '----------------------------'
          soap_request = setSOAPRequestXML('SendPointOrder',xml_file)

          response = csb_post(StorageConfig.config["csb_interface"]["send_point_order_url"],soap_request)
          xml_file_return = response.body.to_s
          # puts xml_file_return
          # puts "@@call_flg=" << @@call_flg.to_s
          xml_file_trans_status = parseAndSaveSendPointOrder(xml_file_return,order_type)
          # puts '----------------------------'
          # puts xml_file_trans_status
          soap_request = setSOAPRequestXML('PointUpdateTransStatus',xml_file_trans_status)
          # puts StorageConfig.config["csb_interface"]["point_update_trans_status_url"]
          # puts '----------------------------'
          # puts soap_request
          response = csb_post(StorageConfig.config["csb_interface"]["point_update_trans_status_url"],soap_request)
          # puts response.body
          # puts '-----------end-----------------'

        end while !@@call_flg
      end
      # return_array = CSBSendWithSOAP.sendPointOrder()
    rescue Exception => e
      #Rails.errors e.message
      puts e.message
    ensure
      ActiveRecord::Base.connection_pool.release_connection
      # puts "#{@title} : #{@count}"
    end
    
  end

  def self.updatePointOrderStatus()
    # @count += 1
    orders = BcmInterface.csb_notice_array_all()
    begin
      if orders.size == 0
        next
      end
      return_array = CSBSendWithSOAP.updatePointOrderStatus(orders)
      # puts return_array
      if return_array[0]=="0"
        # puts 0
        orders.each do |order|
          notice = DeliverNotice.where(order_id: order.id).last
          notice.status="success"
          notice.send_times=notice.send_times+1
          notice.save
        end
      else
        # puts 1
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
      # puts "#{@title} : #{@count}"
    end
  end

  def self.updatePointOrderStatus(orders)
    xml_file = setUpdatePointOrderStatus(orders)
    # puts 'xml_file:[' << xml_file << ']'
    soap_request = setSOAPRequestXML('UpdatePointOrderStatus',xml_file)
    # puts 'soap_request:[' << soap_request << ']'
    response = csb_post(StorageConfig.config["csb_interface"]["update_point_order_status_url"],soap_request)

    xml_file_return = response.body.to_s
    # puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    # puts xml_file_return
    # puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    parseUpdatePointOrderStatus(xml_file_return)
  end

  def self.pointOrderStatus()
    # @count += 1
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
      #Rails.errors e.message
    ensure
      ActiveRecord::Base.connection_pool.release_connection
      # puts "#{@title} : #{@count}"
    end
  end

  def self.pointOrderStatus(orders)
    xml_file = setPointOrderStatus(orders)
    # puts 'xml_file:[' << xml_file << ']'
    soap_request = setSOAPRequestXML('PointOrderStatus',xml_file)
    # puts 'soap_request:[' << soap_request << ']'
    response = csb_post(StorageConfig.config["csb_interface"]["point_order_status_url"],soap_request)
    xml_file_return = response.body.to_s
    # puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    # puts xml_file_return
    # puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    parsePointOrderStatus(xml_file_return)
  end

  private
  def self.csb_post(uri,body)
    url = URI.parse(uri)
    request = Net::HTTP::Post.new(url.path)
    request.content_type = 'text/xml'
    request.body = body
    response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
  end

  def self.setPointOrderStatus(orders)
    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
    doc = REXML::Document.new       #创建XML内容 

    scoreOrderInfo = doc.add_element('ScoreOrderInfo')
    head = scoreOrderInfo.add_element('Head')
    sender = head.add_element('Sender')
    reciver = head.add_element('Reciver')
    orderTotal = head.add_element('OrderTotal')
    maxTimeValve = head.add_element('MaxTimeValve')
    startRow = head.add_element('startRow')
    rowCount = head.add_element('rowCount')
    messageCode = head.add_element('MessageCode')
    description = head.add_element('Description')
    activeCode = head.add_element('ActiveCode')
    
    sender.add_text StorageConfig.config["csb_interface"]["post_name"]
    reciver.add_text StorageConfig.config["csb_interface"]["bst_name"]
    activeCode.add_text StorageConfig.config["csb_interface"]["active_code"]

    orderDetail = scoreOrderInfo.add_element('OrderDetail')
    # 原始订单
    originalityOrder  = orderDetail.add_element('OriginalityOrder')
    # 合并订单
    combinationOrder = orderDetail.add_element('CombinationOrder')
    
    originalityOrderCount = 0
    combinationOrderCount = 0
    
    orders.each do |order|
      if order.order_details.first.business_deliver_no.blank?
        originalityOrderCount+=1
        orderLabel = originalityOrder.add_element('OrderLabel')

        order.order_details.each do |detail|
          giftInfo  = orderLabel.add_element('GiftInfo')

          relationship = Relationship.find_relationship(detail.specification_id,StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'])
          giftInfo.add_attribute('ItemNo', relationship.external_code)
          # 原始订单中的listid和orderID数据是原始订单号
          giftInfo.add_attribute('GiftLineId', order.business_order_id)
          # 4：本人签收，5：他人代收，7：退货
          if order.status == Order::STATUS[:delivered]
            orderLabel.add_attribute('OrderStatus','4')
            giftInfo.add_attribute('RealStatus', '4')
          elsif order.status == Order::STATUS[:declined] or order.status == Order::STATUS[:returned]
            orderLabel.add_attribute('OrderStatus','7')
            giftInfo.add_attribute('RealStatus', '7')
          end
        end
      
        # 原始订单中的listid和orderID数据是原始订单号
        orderLabel.add_attribute('ListID',order.business_order_id)
      else
        combinationOrderCount+=1
        mergerOrderLabel  = combinationOrder.add_element('MergerOrderLabel')
        # MergerOrderLabel BigOrderId="B105"归并的大订单号
        mergerOrderLabel.add_attribute('BigOrderId',order.business_order_id)

        order.order_details.each do |detail|
          giftDetail = mergerOrderLabel.add_element('GiftDetail')

          relationship = Relationship.find_relationship(detail.specification_id,StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'])
          giftDetail.add_attribute('MergerItemNo', relationship.external_code)
          # 原始订单中的listid和orderID数据是原始订单号
          giftDetail.add_attribute('MergerListID', detail.business_deliver_no)
          giftDetail.add_attribute('MergerOrderId', detail.business_deliver_no)
          # 4：本人签收，5：他人代收，7：退货
          if order.status == Order::STATUS[:delivered]
            mergerOrderLabel.add_attribute('OrderStatus','4')
            giftDetail.add_attribute('MergerRealStatus', '4')
          elsif order.status == Order::STATUS[:declined] or order.status == Order::STATUS[:returned]
            mergerOrderLabel.add_attribute('OrderStatus','7')
            giftDetail.add_attribute('MergerRealStatus', '7')
          end
        end
      end
    end
  #  if originalityOrderCount == 0
  #    originalityOrder.add_attribute('isnull','no')
  #  else
  #    originalityOrder.add_attribute('isnull','is')
  #  end
  #  if combinationOrderCount == 0
  #    combinationOrder.add_attribute('isnull','no')
  #  else
  #    combinationOrder.add_attribute('isnull','is')
  #  end
    
    xml_file << doc.to_s
  end

  def self.setUpdatePointOrderStatus(orders)
    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
    doc = REXML::Document.new       #创建XML内容 

    scoreOrderInfo = doc.add_element('ScoreOrderInfo')
    head = scoreOrderInfo.add_element('Head')
    sender = head.add_element('Sender')
    reciver = head.add_element('Reciver')
    sender.add_text StorageConfig.config["csb_interface"]["post_name"]
    reciver.add_text StorageConfig.config["csb_interface"]["bst_name"]
    
    queryLists = scoreOrderInfo.add_element('queryLists')
    orders.each do |order|
      order.order_details.each do |detail|
        queryList = queryLists.add_element('queryList')
        operator = queryList.add_element('Operator')
        operationDepartment = queryList.add_element('operationDepartment')
        abnormalReason = queryList.add_element('abnormalReason')
        state = queryList.add_element('state')
        operatorTime = queryList.add_element('operatorTime')
        signer = queryList.add_element('signer')
        operatorTel = queryList.add_element('operatorTel')
        orderListId = queryList.add_element('orderListId')
        hostNumber = queryList.add_element('hostNumber')
        courier = queryList.add_element('courier')
        courierTel = queryList.add_element('courierTel')
        
        abnormalReason.add_text ""
        if order.status == 'delivering' or order.status == 'delivered'
            operator.add_text "操作人"
          operationDepartment.add_text "站点"
          state.add_text Order::STATUS[order.status.to_sym]
          signer.add_text ""
          operatorTel.add_text ""
        else
          operator.add_text "操作人"
          operationDepartment.add_text "仓库"
          state.add_text Order::STATUS[order.status.to_sym]
          signer.add_text ""
          operatorTel.add_text ""  
        end
        operatorTime.add_text Time.now.strftime("%Y-%m-%d %H:%m:%S")
        if order.tracking_number
          hostNumber.add_text order.tracking_number
        else
          hostNumber.add_text "000000"
        end
        courier.add_text ""
        courierTel.add_text ""
        if detail.business_deliver_no.blank?
          orderListId.add_text order.business_order_id
          break
        else
          orderListId.add_text detail.business_deliver_no
        end
      end
    end

    xml_file << doc.to_s
  end

  def self.setSendPointOrder(order_type)
    current_date = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    start_date = (DateTime.now - StorageConfig.config["csb_interface"]["query_period"]).strftime("%Y-%m-%d %H:%M:%S")
  #current_date = "2014-01-20"
  #start_date = "2014-01-19"
  #if order_type == 1
  #  current_date = "2014-01-20"
  #  start_date = "2014-01-19"
  #else
  #  current_date = "2014-02-17"
  #  start_date = "2014-02-16"
  #end

    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
    doc = REXML::Document.new       #创建XML内容 

    scoreOrderInfo = doc.add_element('ScoreOrderInfo')
    head = scoreOrderInfo.add_element('Head')
    sender = head.add_element('Sender')
    reciver = head.add_element('Reciver')
    orderTotal = head.add_element('OrderTotal')
    maxTimeValve = head.add_element('MaxTimeValve')
    orderType = head.add_element('OrderType')
    startRow = head.add_element('startRow')
    rowCount = head.add_element('rowCount')
    messageCode = head.add_element('MessageCode')
    description = head.add_element('Description')
    activeCode = head.add_element('ActiveCode')

    queryOrder = scoreOrderInfo.add_element('QueryOrder')
    beginDate = queryOrder.add_element('BeginDate')
    endDate = queryOrder.add_element('EndDate')

    sender.add_text StorageConfig.config["csb_interface"]["post_name"]
    reciver.add_text StorageConfig.config["csb_interface"]["bst_name"]
    # orderTotal.add_text "7"
    maxTimeValve.add_text StorageConfig.config["csb_interface"]["max_time_valve"].to_s
    orderType.add_text order_type.to_s
    startRow.add_text '1'
    rowCount.add_text "5"
    # messageCode.add_text "错误信息code"
    # description.add_text "错误信息描述"
    activeCode.add_text StorageConfig.config["csb_interface"]["active_code"]
    beginDate.add_text start_date
    endDate.add_text current_date

    xml_file << doc.to_s
    # xml_file.encode(:xml => :text)
  end

  def self.setSOAPRequestXML(service_name,xml_soap)
    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
    doc = REXML::Document.new       #创建XML内容

    envelope = doc.add_element('SOAP-ENV:Envelope')
    envelope.add_attribute('xmlns:SOAP-ENV',"http://schemas.xmlsoap.org/soap/envelope/")
    envelope.add_attribute('xmlns:SOAP-ENC',"http://schemas.xmlsoap.org/soap/encoding/")
    envelope.add_attribute('xmlns:xsi',"http://www.w3.org/2001/XMLSchema-instance")
    envelope.add_attribute('xmlns:xsd',"http://www.w3.org/2001/XMLSchema")
    envelope.add_attribute('xmlns:m0',"http://www.shtel.com.cn/csb/v2/")
    envelope.add_attribute('xmlns:m1',"http://schemas.xmlsoap.org/soap/encoding/")

    header = envelope.add_element('SOAP-ENV:Header')
    csb_header = header.add_element('m:CSBHeader')
    csb_header.add_attribute('xmlns:m',"http://www.shtel.com.cn/csb/v2/")

    serviceName = csb_header.add_element('ServiceName')
    serviceVer = csb_header.add_element('ServiceVer')
    consumer = csb_header.add_element('Consumer')
    requestTime = csb_header.add_element('RequestTime')

    serviceName.add_text(service_name)
    serviceVer.add_text('1.0')
    consumer.add_text('闸北邮政')
    requestTime.add_text(Time.now.strftime("%Y-%m-%d %H:%m:%S"))

    body = envelope.add_element('SOAP-ENV:Body')
  soap_action = nil
  if service_name == "SendPointOrder"
    soap_action = body.add_element('m:sendQueryOrder')
  elsif service_name == "PointUpdateTransStatus"
    soap_action = body.add_element('m:updateTransportStatus')
  elsif service_name == "UpdatePointOrderStatus"
    soap_action = body.add_element('m:updateQueryOrderStatus')
  elsif service_name == "PointOrderStatus"
    soap_action = body.add_element('m:OrderStatus')
  end
    soap_action.add_attribute('xmlns:m', "http://localhost:8080/services/0rderWS")
    soap_action.add_attribute('SOAP-ENV:encodingStyle', "http://schemas.xmlsoap.org/soap/encoding/")
    soap_params = soap_action.add_element('xmlFile')
    soap_params.add_text(xml_soap)

    xml_file << doc.to_s
  end

  def self.parseAndSaveSendPointOrder(xml_file,order_type)
    orderTransStatus = Array.new
  doc = REXML::Document.new(xml_file)
  xml_body = doc.root.elements['soapenv:Body'].elements['ns1:sendQueryOrderResponse'].elements['sendQueryOrderReturn'].text.to_s
  # default encoding is utf-8 in ruby
    doc = REXML::Document.new(xml_body.gsub('encoding="gb2312"','encoding="utf-8"')) 
  #puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  #puts doc
    #puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  root = doc.root
    head = root.elements['Head']
    orderTotal = head.elements['OrderTotal']
    startRow = head.elements['startRow']
    rowCount = head.elements['rowCount']
  orderTotal_s = orderTotal.text
  rowCount_s = rowCount.text
  rowsum = 0
    # queryCondition = root.elements['QueryCondition']
    # beginDate = queryCondition.elements['BeginDate']
  
  messageCode = head.elements['MessageCode'].text
    description = head.elements['Description'].text
  if messageCode != '0'
    return description
  end

    orderDetail = root.elements['OrderDetail']
    orders = nil
    if order_type == StorageConfig.config["csb_interface"]["order_type_1"]
      orders = orderDetail.elements['OriginalityOrder']
    else
      orders = orderDetail.elements['CombinationOrder']
    end
    orders.each_element('OrderLabel') { |orderLabel|
      order_hash = {}
      orderId = nil
      if order_type == StorageConfig.config["csb_interface"]["order_type_1"]
        orderId = orderLabel.attributes['listId']
      else
        orderId = orderLabel.attributes['BigOrderId']
      end
      createDate = orderLabel.attributes['CreateDate']
      customerName = orderLabel.attributes['CustomerName']
      address = orderLabel.attributes['Address']
      telephone = orderLabel.attributes['Telephone']
      customerArea = orderLabel.attributes['CustomerArea']
      deadLineDate = orderLabel.attributes['DeadLineDate']
      custRemark = orderLabel.attributes['CustRemark']
      
      order_hash.store('ORDER_ID',orderId)
    #puts "ORDER_ID=" << orderId
      order_hash.store('DATE',createDate)
      order_hash.store('CUST_NAME',customerName)
    #puts "CUST_NAME=" << customerName
      order_hash.store('ADDR',address)
    #puts "ADDR=" << address
      order_hash.store('MOBILE',telephone)
      order_hash.store('ZIP',customerArea)
      order_hash.store('DESC',custRemark)

      order_details = Array.new
      orderLabel.each_element('GiftDetail') { |giftDetail|
        order_detail = {}
        itemId = giftDetail.attributes['itemId']
        giftLineId = giftDetail.attributes['giftLineId']
        giftName = giftDetail.attributes['GiftName']
        changeNumber = giftDetail.attributes['ChangeNumber']
        scoreValue = giftDetail.attributes['ScoreValue']
        if order_type == StorageConfig.config["csb_interface"]["order_type_2"]
          listId = giftDetail.attributes['listId']
        #puts "DELIVER_NO=" << listId
          order_detail.store('DELIVER_NO', listId)
        end

        order_detail.store('SKU', itemId)
        #puts "SKU=" << itemId
        order_detail.store('DESC', giftName)
        #puts "DESC=" << giftName
        order_detail.store('QTY', changeNumber)
        order_detail.store('PRICE', scoreValue)

        order_details << order_detail
      }

      order_hash.store('ORDER_DETAILS', order_details)
      #puts order_hash
      order = StandardInterface.order_enter(order_hash, Business.find(StorageConfig.config["business"]['bst_id']), Unit.find(StorageConfig.config["unit"]['zb_id']))
      if !order.blank?
        orderTransStatus << orderId
          rowsum += 1
      else
        next
        # return true
      end
    }
  # puts '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
  # puts "orderTotal=" << orderTotal_s
  # puts "rowCount=" << rowCount_s
  # puts "rowsum=" << rowsum.to_s
  if orderTotal_s == rowCount_s && rowsum.to_s == rowCount_s
    @@call_flg = true
  end
  # puts "@@call_flg=" << @@call_flg.to_s
  # puts '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
    setPointUpdateTransStatus(orderTransStatus, order_type)
  end

  def self.setPointUpdateTransStatus(order_ids, order_type)
    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
    doc = REXML::Document.new       #创建XML内容 

    scoreOrderInfo = doc.add_element('ScoreOrderInfo')
    head = scoreOrderInfo.add_element('Head')
    sender = head.add_element('Sender')
    reciver = head.add_element('Reciver')
    orderTotal = head.add_element('OrderTotal')
    maxTimeValve = head.add_element('MaxTimeValve')
    orderType = head.add_element('OrderType')
    startRow = head.add_element('startRow')
    rowCount = head.add_element('rowCount')
    messageCode = head.add_element('MessageCode')
    description = head.add_element('Description')
    activeCode = head.add_element('ActiveCode')

    sender.add_text StorageConfig.config["csb_interface"]["post_name"]
    reciver.add_text StorageConfig.config["csb_interface"]["bst_name"]
    # orderTotal.add_text "7"
    # maxTimeValve.add_text StorageConfig.config["csb_interface"]["max_time_valve"].to_s
    orderType.add_text order_type.to_s
    # startRow.add_text '1'
    # rowCount.add_text "行数统计"
    # messageCode.add_text "错误信息code"
    description.add_text "订单返回信息"
    activeCode.add_text StorageConfig.config["csb_interface"]["active_code"]

    orderDetail = scoreOrderInfo.add_element('OrderDetail')
    order_ids.each do |id|
      orderLabel = orderDetail.add_element('OrderLabel')
      orderLabel.add_attribute('orderId', id)
      orderLabel.add_attribute('isReceive', 'y')
    end

    xml_file << doc.to_s
    #xml_file.encode(:xml => :text)
  end

  def self.parseUpdatePointOrderStatus(xml_file)
    doc = REXML::Document.new(xml_file)
    xml_body = doc.root.elements['soapenv:Body'].elements['ns1:updateQueryOrderStatusResponse'].elements['updateQueryOrderStatusReturn'].text.to_s
    # default encoding is utf-8 in ruby
    doc = REXML::Document.new(xml_body.gsub('encoding="gb2312"','encoding="utf-8"')) 
    # puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    # puts doc
    # puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    root = doc.root
    head = root.elements['Head']
    sender = head.elements['Sender']
    reciver = head.elements['Reciver']

    resultInfo = root.elements['resultInfo']
    sqlcount = resultInfo.elements['sqlcount']
    result = resultInfo.elements['result']
    message = resultInfo.elements['message']

    return_array = []
    # puts result.text
    # puts message.text
    return_array << result.text << message.text
    return return_array
  end

  def self.parsePointOrderStatus(xml_file)
    doc = REXML::Document.new(xml_file)
    xml_body = doc.root.elements['soapenv:Body'].elements['ns1:OrderStatusResponse'].elements['OrderStatusReturn'].text.to_s
    # default encoding is utf-8 in ruby
    doc = REXML::Document.new(xml_body.gsub('encoding="gb2312"','encoding="utf-8"')) 
    # puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    # puts doc
    # puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    root = doc.root
    head = root.elements['Head']
    sender = head.elements['Sender']
    reciver = head.elements['Reciver']
    total = head.elements['Total']
    messageCode = head.elements['MessageCode']
    description = head.elements['Description']
    activeCode = head.elements['ActiveCode']

    return_array = []
    if messageCode.text.blank?
      return_array << '0' << ''
    else
      return_array << messageCode.text << description.text
    end
    return return_array
  end

  def self.parsePointUpdateTransStatus(xml_file)
    doc = REXML::Document.new(decode_xml(xml_file)) 
    root = doc.root
    head = root.elements['Head']
    sender = head.elements['Sender']
    reciver = head.elements['Reciver']
    orderTotal = head.elements['OrderTotal']
    messageCode = head.elements['MessageCode']
    description = head.elements['Description']
    activeCode = head.elements['ActiveCode']

    return_array = []
    if messageCode.text.blank?
      return_array << '0' << ''
    else
      return_array << messageCode.text << description.text
    end
    return return_array
  end

  def self.decode_xml(xml_get)
    xml_get = xml_get.gsub('&lt;','<')
    xml_get = xml_get.gsub('&gt;','>')
    xml_get = xml_get.gsub('&amp;','=')
    xml_get = xml_get.gsub('&quot;','"')
  end

  def self.getClient(serviceName)
    Savon.client(wsdl: StorageConfig.config["csb_interface"]["csb_url"],
    soap_header: {
      'CSBHeader' => {
        'ServiceName' => "#{serviceName}",
        'ServiceVer' => '1.0',
        'Consumer' => '邮政',
        'RequestTime' => Time.now.strftime("%Y-%m-%d %H:%m:%S")
      }
    },
    env_namespace: 'SOAP-ENV'.to_sym,
    namespace_identifier: :m,
    namespaces: {'xmlns:m0'=>'http://www.shtel.com.cn/csb/v2/'})
  end
end