class BcmInterface < ActiveRecord::Base
	status_hash ={'delivering'=>'00','delivered'=>'01','waiting'=>'02','printed'=>'03','checked'=>'04','picking'=>'05','packed'=>'06','declined'=>'07','returned'=>'08'}
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
		dn1=Order.where( business_id: business, unit_id: unit, status: status ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=?",status_hash[status],"success"])
		dn1.each do |dn|
			array<<dn
		end
		dn2=Order.where( business_id: business, unit_id: unit, status: status ).includes(:deliver_notices).where(["deliver_notices.id is ?",nil])
		dn2.each do |dn|
			Deliver_notice.create!( :order_id => dn.id, :send_type => status_hash[status])
			array<<dn
		end
		return array
	end
end
