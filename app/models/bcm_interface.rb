class BcmInterface
	STATUS_HASH ={'delivering'=>'00','delivered'=>'01','waiting'=>'02','printed'=>'03','checked'=>'04','picking'=>'05','packed'=>'06','declined'=>'07','returned'=>'08','cancel'=>'09'}
	# def self.notice_array(business,unit)
	# 	array=[]
	# 	dn1=Order.where( business_id: business, unit_id: unit, status: "delivering" ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=?","00","success"])
	# 	dn1.each do |dn|
	# 		array<<dn
	# 	end
	# 	dn2=Order.where( business_id: business, unit_id: unit, status: "delivered" ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=?","01","success"])
	# 	dn2.each do |dn|
	# 		array<<dn
	# 	end
	# 	dn3=Order.where( business_id: business, unit_id: unit, status: "delivering" ).includes(:deliver_notices).where(["deliver_notices.id is ?",nil])
	# 	dn3.each do |dn|
	# 		Deliver_notice.create!( :order_id => dn.id, :send_type => "00")
	# 		array<<dn
	# 	end
	# 	dn4=Order.where( business_id: business, unit_id: unit, status: "delivered" ).includes(:deliver_notices).where(["deliver_notices.id is ?",nil])
	# 	dn4.each do |dn|
	# 		Deliver_notice.create!( :order_id => dn.id, :send_type => "01")
	# 		array<<dn
	# 	end
	# 	return array
	# end

	def self.notice_array(business,unit,status)
    array=[]
		dn1=Order.where( business_id: business, unit_id: unit, status: status ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=? and deliver_notices.status!=?",STATUS_HASH[status],"success","over"])
		dn1.each do |dn|
			array<<dn
		end
		dn2=Order.where( business_id: business, unit_id: unit, status: status ).includes(:deliver_notices)
	#	dn2=Order.where( business_id: business, unit_id: unit, status: status ).joins("LEFT JOIN deliver_notices ON deliver_notices.order_id = orders.id AND deliver_notices.status = '",STATUS_HASH[status],"'")
		dn2.each do |dn|
			exist_flg = false
			dn.deliver_notices.each do |notice|
				if notice.send_type == STATUS_HASH[status]
					exist_flg = true
					break
				end
			end
			if !exist_flg
				DeliverNotice.create!( :order_id => dn.id, :send_type => STATUS_HASH[status], status: 'sending')
				array<<dn
			end
		end
		return array
	end
	
	def self.notice_array_over(business,unit,status)
		array=[]
		dn1=Order.where( business_id: business, unit_id: unit, status: status ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=?",STATUS_HASH[status],"over"])
		dn1.each do |dn|
			array<<dn
		end
		dn2=Order.where( business_id: business, unit_id: unit, status: status ).includes(:deliver_notices)
	#	dn2=Order.where( business_id: business, unit_id: unit, status: status ).joins("LEFT JOIN deliver_notices ON deliver_notices.order_id = orders.id AND deliver_notices.status = '",STATUS_HASH[status],"'")
		dn2.each do |dn|
			exist_flg = false
			dn.deliver_notices.each do |notice|
				if notice.send_type == STATUS_HASH[status]
					exist_flg = true
					break
				end
			end
			if !exist_flg
				DeliverNotice.create!( :order_id => dn.id, :send_type => STATUS_HASH[status], status: 'sending')
				array<<dn
			end
		end
		return array
	end

	def self.csb_notice_array_all()
		orders_return = []
		status_keys = STATUS_HASH.keys
		# puts status_keys
		status_keys.each do |key|
			# puts "*************"
			# puts key
			orders = BcmInterface.notice_array(Business.find_by(no: StorageConfig.config["business"]['bst_id']).id, Unit.find_by(no: StorageConfig.config["unit"]['zb_id']).id, key)
			# puts orders.size
			orders.each do |order|
				orders_return << order
			end
		end
		# puts orders_return.size
		orders_return
	end

	def self.csb_notice_array()
		orders_return = []
		status_keys = ["delivered","declined","returned","cancel"]
		# puts status_keys
		status_keys.each do |key|
			# puts "*************"
			# puts key
			orders = BcmInterface.notice_array_over(Business.find_by(no: StorageConfig.config["business"]['bst_id']).id, Unit.find_by(no: StorageConfig.config["unit"]['zb_id']).id, key)
			# puts orders.size
			orders.each do |order|
				orders_return << order
			end
		end
		# puts orders_return.size
		orders_return
	end
end
