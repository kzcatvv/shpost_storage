class BcmInterface < ActiveRecord::Base
	def self.notice_array(business,unit)
		array=[]
		dn1=Order.where( business_id: business, unit_id: unit, status: "delivering" ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=?","00","success"])
		dn1.each do |dn|
			array<<dn
		end
		dn2=Order.where( business_id: business, unit_id: unit, status: "delivered" ).includes(:deliver_notices).where(["deliver_notices.send_type=? and deliver_notices.status!=?","01","success"])
		dn2.each do |dn|
			array<<dn
		end
		dn3=Order.where( business_id: business, unit_id: unit, status: "delivering" ).includes(:deliver_notices).where(["deliver_notices.id is ?",nil])
		dn3.each do |dn|
			Deliver_notice.create!( :order_id => dn.id, :send_type => "00")
			array<<dn
		end
		dn4=Order.where( business_id: business, unit_id: unit, status: "delivered" ).includes(:deliver_notices).where(["deliver_notices.id is ?",nil])
		dn4.each do |dn|
			Deliver_notice.create!( :order_id => dn.id, :send_type => "01")
			array<<dn
		end
		return array
	end
end
