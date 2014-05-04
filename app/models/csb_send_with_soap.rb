class CSBSendWithSOAP
	require "rexml/document"

	@@startrow = 1
	@@client = Savon.client(wsdl: StorageConfig.config["csb_interface"]["csb_url"],
		soap_header: {
			'CSBHeader' => {
				'ServiceName' => 'SendPointOrder',
				'ServiceVer' => '1.0',
				'Consumer' => '网厅',
				'RequestTime' => Time.now.strftime("%Y-%m-%d %H:%m:%S")
			}
		},
		env_namespace: 'SOAP-ENV'.to_sym,
		namespace_identifier: :m,
		namespaces: {'xmlns:m0'=>'http://www.shtel.com.cn/csb/v2/'})

	def self.sendPointOrder()
		for order_type in 1..2
			puts order_type
			call_flg = false
			@@startrow = 1
			begin 
				xml_file = setSendPointOrder(order_type)
				# puts '----------------------------'
				# puts xml_file
				# puts '----------------------------'
				# puts decode_xml(xml_file)
				# puts '----------------------------'
	      send_hash = { "xmlFile" => xml_file}
	      response = @@client.call("sendQueryOrder".to_sym, message: send_hash)

	      xml_file_return = response.body[:sendQueryOrder][:sendQueryOrderReturn].to_s
		    call_flg = parseAndSaveSendPointOrder(xml_file_return,order_type)
			end while call_flg
		end
  end

  def self.updatePointOrderStatus(orders)
	  	xml_file = setUpdatePointOrderStatus(orders)
	  	send_hash = { "xmlFile" => xml_file}
      response = @@client.call("updateQueryOrderStatus".to_sym, message: send_hash)

      xml_file_return = response.body[:updateQueryOrderStatus][:updateQueryOrderStatusReturn].to_s
	    parseUpdatePointOrderStatus(xml_file_return)
  end

	def self.pointOrderStatus(orders)
		puts '------------todo:pointOrderStatus function--------------'
		xml_file = setPointOrderStatus(orders)
	  	send_hash = { "inputXml" => xml_file}
      response = @@client.call("OrderStatus".to_sym, message: send_hash)

      xml_file_return = response.body[:OrderStatus][:OrderStatusReturn].to_s
      parsePointOrderStatus(xml_file_return)
  end

  private
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

		orderDetail = scoreOrderInfo.add_element('OrderDetail')
		# 原始订单
		originalityOrder  = scoreOrderInfo.add_element('OriginalityOrder')
		# 合并订单
		combinationOrder = scoreOrderInfo.add_element('CombinationOrder')

  	originalityOrder.add_attributes('isnull','xxxxxxxxxxxxxxxxxx')
  	combinationOrder.add_attributes('isnull','xxxxxxxxxxxxxxxxxx')

		orders.each do |order|
			if order.order_details.first.business_deliver_no.blank?
				orderLabel = originalityOrder.add_element('OrderLabel')
				# 原始订单中的listid和orderID数据是原始订单号
				orderLabel.add_attributes('listID',order.business_order_id)

				order.order_details.each do |detail|
					giftInfo  = originalityOrder.add_element('GiftInfo')

					relationship = Relationship.find_relationship(detail.specification_id,StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'])
					giftInfo.add_attributes('ItemNo', relationship.external_code)
					# 原始订单中的listid和orderID数据是原始订单号
					giftInfo.add_attributes('OrderId', order.business_order_id)
					# 4：本人签收，5：他人代收，7：退货
					if order.status == ORDER::STATUS[:delivered]
						giftDetail.add_attributes('realStatus', '4')
					elsif order.status == ORDER::STATUS[:declined]
						giftDetail.add_attributes('realStatus', '7')
					end
				end
			else
				combinationOrder  = originalityOrder.add_element('CombinationOrder')
				# MergerOrderLabel BigOrderId="B105"归并的大订单号
				combinationOrder.add_attributes('BigOrderId',order.business_order_id)

				order.order_details.each do |detail|
					giftDetail = originalityOrder.add_element('GiftDetail')

					relationship = Relationship.find_relationship(detail.specification_id,StorageConfig.config["business"]['bst_id'], StorageConfig.config["unit"]['zb_id'])
					giftDetail.add_attributes('MergerItemNo', relationship.external_code)
					# 原始订单中的listid和orderID数据是原始订单号
					giftDetail.add_attributes('MergerListID', detail.business_deliver_no)
					giftDetail.add_attributes('MergerOrderId', detail.business_deliver_no)
					# 4：本人签收，5：他人代收，7：退货
					if order.status == ORDER::STATUS[:delivered]
						giftDetail.add_attributes('MergerRealStatus', '4')
					elsif order.status == ORDER::STATUS[:declined]
						giftDetail.add_attributes('MergerRealStatus', '7')
					end
				end
			end
		end
  end

  def self.setUpdatePointOrderStatus(orders)
    xml_file = '<?xml version="1.0" encoding="utf-8" ?>';
  	doc = REXML::Document.new       #创建XML内容 

  	scoreOrderInfo = doc.add_element('ScoreOrderInfo')
		head = scoreOrderInfo.add_element('Head')
		sender = head.add_element('Sender')
		reciver = head.add_element('Reciver')

		queryLists = scoreOrderInfo.add_element('QueryLists')
		orders.each do |order|
			order.order_details.each do |detail|
				queryList = queryLists.add_element('QueryList')
				operator = queryList.add_element('Operator')
				operationDepartment = queryList.add_element('OperationDepartment')
				abnormalReason = queryList.add_element('AbnormalReason')
				state = queryList.add_element('State')
				operatorTime = queryList.add_element('OperatorTime')
				signer = queryList.add_element('Signer')
				operatorTel = queryList.add_element('OperatorTel')
				orderListId = queryList.add_element('OrderListId')
				hostNumber = queryList.add_element('HostNumber')
				courier = queryList.add_element('Courier')
				courierTel = queryList.add_element('CourierTel')
				
				# abnormalReason.add_text ""
				if !order.status == 'delivering'
					operator.add_text "仓库人员"
					operationDepartment.add_text "仓库"
					state.add_text ORDER::STATUS[order.status]
					signer.add_text "仓库人员"
					operatorTel.add_text "操作人联系电话"
				elsif order.status == 'delivering'
					operator.add_text "操作人"
					operationDepartment.add_text "站点"
					state.add_text "物流状态信息描述"
					signer.add_text "操作人"
					operatorTel.add_text "操作人联系电话"
				end
				operatorTime.add_text Time.now.strftime("%Y-%m-%d %H:%m:%S")
				if order.tracking_number
					hostNumber.add_text order.tracking_number
				end
				# courier.add_text ""
				# courierTel.add_text ""
				if detail.business_deliver_no.blank?
					orderListId.add_text order.business_order_id
					break
				else
					orderListId.add_text detail.business_deliver_no
				end
			end
		end

		xml_file << doc.to_s
		puts xml_file
		xml_file.encode(:xml => :text)
  end

  def self.setSendPointOrder(order_type)
  	current_date = DateTime.now.strftime("%Y-%m-%d")
  	start_date = (DateTime.now - StorageConfig.config["csb_interface"]["query_period"]).strftime("%Y-%m-%d")

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
		if order_type == StorageConfig.config["csb_interface"]["order_type_1"]
			orderType.add_text StorageConfig.config["csb_interface"]["order_type_1"].to_s
		else
			orderType.add_text StorageConfig.config["csb_interface"]["order_type_2"].to_s
		end
		startRow.add_text @@startrow.to_s
		# rowCount.add_text "行数统计"
		# messageCode.add_text "错误信息code"
		# description.add_text "错误信息描述"
		activeCode.add_text StorageConfig.config["csb_interface"]["active_code"]
		puts current_date
		puts start_date
		beginDate.add_text start_date+' '+StorageConfig.config["csb_interface"]["query_time"]
		endDate.add_text current_date+' '+StorageConfig.config["csb_interface"]["query_time"]


		# # for test
		# if order_type == StorageConfig.config["csb_interface"]["order_type_1"]
		# orderDetail = scoreOrderInfo.add_element('OrderDetail')
		# originalityOrder = orderDetail.add_element('OriginalityOrder')
		# orderLabel1 = originalityOrder.add_element('OrderLabel',{'listId'=>'订单号1', 'CreateDate'=>'创建时间', 'CustomerName'=>'客户姓名1', 'Address'=>'联系地址', 'Telephone'=>'联系电话', 'CustomerArea'=>'邮编', 'DeadLineDate'=>'', 'CustRemark'=>'客户备注'})
		# giftDetail1 = orderLabel1.add_element('GiftDetail',{'itemId'=>'礼品编号1', 'giftLineId'=>'礼品单编号1', 'GiftName'=>'礼品名称1', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# giftDetail2 = orderLabel1.add_element('GiftDetail',{'itemId'=>'礼品编号2', 'giftLineId'=>'礼品单编号1', 'GiftName'=>'礼品名称2', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})

		# orderLabel2 = originalityOrder.add_element('OrderLabel',{'listId'=>'订单号2', 'CreateDate'=>'创建时间', 'CustomerName'=>'客户姓名2', 'Address'=>'联系地址', 'Telephone'=>'联系电话', 'CustomerArea'=>'邮编', 'DeadLineDate'=>'', 'CustRemark'=>'客户备注'})
		# giftDetail3 = orderLabel2.add_element('GiftDetail',{'itemId'=>'礼品编号3', 'giftLineId'=>'礼品单编号2', 'GiftName'=>'礼品名称1', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# giftDetail4 = orderLabel2.add_element('GiftDetail',{'itemId'=>'礼品编号4', 'giftLineId'=>'礼品单编号2', 'GiftName'=>'礼品名称2', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# else
		# orderDetail = scoreOrderInfo.add_element('OrderDetail')
		# originalityOrder = orderDetail.add_element('CombinationOrder')
		# orderLabel1 = originalityOrder.add_element('OrderLabel',{'BigOrderId'=>'归并订单号1', 'CreateDate'=>'创建时间', 'CustomerName'=>'客户姓名1', 'Address'=>'联系地址', 'Telephone'=>'联系电话', 'CustomerArea'=>'邮编', 'DeadLineDate'=>'', 'CustRemark'=>'客户备注'})
		# giftDetail1 = orderLabel1.add_element('GiftDetail',{'listId'=>'订单号1','itemId'=>'礼品编号1', 'giftLineId'=>'礼品单编号1', 'GiftName'=>'礼品名称1', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# giftDetail2 = orderLabel1.add_element('GiftDetail',{'listId'=>'订单号2','itemId'=>'礼品编号2', 'giftLineId'=>'礼品单编号1', 'GiftName'=>'礼品名称2', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})

		# orderLabel2 = originalityOrder.add_element('OrderLabel',{'BigOrderId'=>'归并订单号2', 'CreateDate'=>'创建时间', 'CustomerName'=>'客户姓名2', 'Address'=>'联系地址', 'Telephone'=>'联系电话', 'CustomerArea'=>'邮编', 'DeadLineDate'=>'', 'CustRemark'=>'客户备注'})
		# giftDetail3 = orderLabel2.add_element('GiftDetail',{'listId'=>'订单号3','itemId'=>'礼品编号3', 'giftLineId'=>'礼品单编号2', 'GiftName'=>'礼品名称1', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# giftDetail4 = orderLabel2.add_element('GiftDetail',{'listId'=>'订单号4','itemId'=>'礼品编号4', 'giftLineId'=>'礼品单编号2', 'GiftName'=>'礼品名称2', 'ChangeNumber'=>'兑换数量', 'ScoreValue'=>'礼品单价'})
		# end
		# # for test

		xml_file << doc.to_s
		xml_file.encode(:xml => :text)
  end

  def self.parseAndSaveSendPointOrder(xml_file,order_type)
  	doc = REXML::Document.new(decode_xml(xml_file)) 
  	root = doc.root
  	head = root.elements['Head']
  	orderTotal = head.elements['OrderTotal']
  	startRow = head.elements['startRow']
  	rowCount = head.elements['rowCount']

  	# queryCondition = root.elements['QueryCondition']
  	# beginDate = queryCondition.elements['BeginDate']

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
  			if order_type == StorageConfig.config["csb_interface"]["order_type_2"]
	  			listId = giftDetail.attributes['listId']
	  			order_detail.store('DELIVER_NO', listId)
	  		end

				order_detail.store('SKU', itemId)
				order_detail.store('NAME', giftName)
				order_detail.store('QTY', changeNumber)
				order_detail.store('PRICE', scoreValue)

				order_details << order_detail
  		}

  		order_hash.store('ORDER_DETAILS', order_details)
  		puts order_hash
  		order = StandardInterface.order_enter(order_hash, Business.find(StorageConfig.config["business"]['bst_id']), Business.find(StorageConfig.config["unit"]['zb_id']))
  		if !order.blank?
	      @@startrow += 1
	    else
	      return true
	    end
  	}
  	return orderTotal.text.to_i > @@startrow - 1
	end

	def self.parseUpdatePointOrderStatus(xml_file)
		doc = REXML::Document.new(decode_xml(xml_file)) 
  	root = doc.root
  	head = root.elements['Head']
  	sender = head.elements['Sender']
  	reciver = head.elements['Reciver']

  	resultInfo = root.elements['resultInfo']
  	sqlcount = resultInfo.elements['sqlcount']
  	result = resultInfo.elements['result']
  	message = resultInfo.elements['message']

  	return_array = []
  	return_array << result.text << message.text
  	return return_array
	end

	def self.parsePointOrderStatus(xml_file)
		doc = REXML::Document.new(decode_xml(xml_file)) 
  	root = doc.root
  	head = root.elements['Head']
  	sender = head.elements['Sender']
  	reciver = head.elements['Reciver']
  	total = head.elements['Total']
  	processCode = head.elements['ProcessCode']
  	description = head.elements['Description']
  	activeCode = head.elements['ActiveCode']

  	return_array = []
  	if processCode.text.blank?
  		return_array << '0' << ''
  	else
  		return_array << processCode.text << description.text
  	end
  	return return_array
	end

	def self.decode_xml(xml_get)
		xml_get = xml_get.gsub('&lt;','<')
		xml_get = xml_get.gsub('&gt;','>')
		xml_get = xml_get.gsub('&amp;','=')
		xml_get = xml_get.gsub('&quot;','"')
	end
end