class CSBSendWithSOAP
	require "rexml/document"

	@@startrow = 1
	# @@client = Savon.client(wsdl: "http://222.68.185.223:8080/scoreProject/services/0rderWS?wsdl")

	def self.sendorder(maxtimevalve = 1, ordertotal = 1)
		call_flg = false
		begin 
			xml_file = setSendPointOrder()
			puts xml_file
			# puts '----------------------------'
	    # if test_mod?
	    #   {"code"=>"0", "message"=>"testMessage"}.to_json
	    # else
	      # send_hash = { "token" => "wydc", "publicNameWithOpenid" => publicid + "," + openid, "text" => text, "keyWithSignAndMode" => "," + sign + ",1" }
	      # response = @@client.call("send_text".to_sym, message: send_hash)

	      # response.body[:sendQueryOrderReturn][:return].to_s
	    # end
	    call_flg = parseAndSaveSendPointOrder(xml_file)
	  end while call_flg
  end

  private
  def self.setSendPointOrder()
  	current_date = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  	xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
  	doc = REXML::Document.new       #创建XML内容 
		#为REXML文档添加一个节点 
		# element = doc.add_element('book',{'name'=>'Programming Ruby','author'=>'Joe Chu'})
		# chapter1 = element.add_element('chapter',{'title'=>'chapter 1'})
		# chapter2 = element.add_element('chapter',{'title'=>'chapter 2'})
		# #为节点添加包含内容
		# chapter1.add_text "Chapter 1 content"
		# chapter2.add_text "Chapter 2 content"

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
		# orderTotal.add_text "订单总数"
		maxTimeValve.add_text StorageConfig.config["csb_interface"]["max_time_valve"].to_s
		orderType.add_text StorageConfig.config["csb_interface"]["order_type_1"].to_s
		startRow.add_text @@startrow.to_s
		# rowCount.add_text "行数统计"
		# messageCode.add_text "错误信息code"
		# description.add_text "错误信息描述"
		activeCode.add_text StorageConfig.config["csb_interface"]["active_code"]
		puts current_date
		beginDate.add_text "开始时间"
		endDate.add_text "结束时间"


		# for test
		orderDetail = scoreOrderInfo.add_element('OrderDetail')
		originalityOrder = orderDetail.add_element('OriginalityOrder')
		orderLabel1 = originalityOrder.add_element('OrderLabel',{'listId'=>'订单号1', 'CreateDate'=>'创建时间', 'CustomerName'=>'客户姓名1', 'Address'=>'联系地址', 'Telephone'=>'联系电话', 'CustomerArea'=>'邮编', 'DeadLineDate'=>'', 'CustRemark'=>'客户备注'})
		giftDetail1 = orderLabel1.add_element('GiftDetail',{'itemId'=>'礼品编号1', 'giftLineId'=>'礼品单编号1', 'GiftName'=>'礼品名称1', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		giftDetail2 = orderLabel1.add_element('GiftDetail',{'itemId'=>'礼品编号2', 'giftLineId'=>'礼品单编号1', 'GiftName'=>'礼品名称2', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})

		orderLabel2 = originalityOrder.add_element('OrderLabel',{'listId'=>'订单号2', 'CreateDate'=>'创建时间', 'CustomerName'=>'客户姓名2', 'Address'=>'联系地址', 'Telephone'=>'联系电话', 'CustomerArea'=>'邮编', 'DeadLineDate'=>'', 'CustRemark'=>'客户备注'})
		giftDetail3 = orderLabel2.add_element('GiftDetail',{'itemId'=>'礼品编号3', 'giftLineId'=>'礼品单编号2', 'GiftName'=>'礼品名称1', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		giftDetail4 = orderLabel2.add_element('GiftDetail',{'itemId'=>'礼品编号4', 'giftLineId'=>'礼品单编号2', 'GiftName'=>'礼品名称2', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# for test

		xml_file << doc.to_s
		xml_file.encode(:xml => :text)
  end

  def self.parseAndSaveSendPointOrder(xml_file)
  	doc = REXML::Document.new(decode_xml(xml_file)) 
  	root = doc.root
  	head = root.elements['Head']
  	orderTotal = head.elements['OrderTotal']
  	startRow = head.elements['startRow']
  	rowCount = head.elements['rowCount']

  	# queryCondition = root.elements['QueryCondition']
  	# beginDate = queryCondition.elements['BeginDate']

  	orderDetail = root.elements['OrderDetail']
  	originalityOrder = orderDetail.elements['OriginalityOrder']
  	originalityOrder.each_element('OrderLabel') { |orderLabel|
  		order_hash = {}

  		listId = orderLabel.attributes['listId']
  		createDate = orderLabel.attributes['CreateDate']
  		customerName = orderLabel.attributes['CustomerName']
  		address = orderLabel.attributes['Address']
  		telephone = orderLabel.attributes['Telephone']
  		customerArea = orderLabel.attributes['CustomerArea']
  		deadLineDate = orderLabel.attributes['DeadLineDate']
  		custRemark = orderLabel.attributes['CustRemark']
  		
  		order_hash.store('ORDER_ID',listId)
  		order_hash.store('DATE',createDate)
  		order_hash.store('CUST_NAME',customerName)
  		order_hash.store('ADDR',address)
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

				order_detail.store('SKU', itemId)
				order_detail.store('NAME', giftName)
				order_detail.store('QTY', changeNumber)
				order_detail.store('PRICE', scoreValue)

				order_details << order_detail
  		}

  		order_hash.store('ORDER_DETAILS', order_details)
  		order = StandardInterface.order_enter(order_hash, Business.find(StorageConfig.config["business"]['bst_id']), Business.find(StorageConfig.config["unit"]['zb_id']))
  		if !order.blank?
	      @@startrow += 1
	    else
	      return true
	    end
  	}
  	return orderTotal > @@startrow - 1
	end

	def self.decode_xml(xml_get)
		xml_get = xml_get.gsub('&lt;','<')
		xml_get = xml_get.gsub('&gt;','>')
		xml_get = xml_get.gsub('&amp;','=')
		xml_get = xml_get.gsub('&quot;','"')
	end
end