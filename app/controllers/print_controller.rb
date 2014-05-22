class PrintController < ApplicationController
	layout false

	def tracking
		@order = Order.find(params[:id])
	end

	def trackingnum
		order = Order.find(params[:id])
		order.tracking_number=params[:num]
		order.status='printed'
		order.user_id=current_user.id
		order.save
		flash[:alert] = "正在打印"
	end

	def keytracking
		@keyclientorder = Keyclientorder.find(params[:id])
	end

	def keytrackingnum
		@transport_type=params[:transport_type]
		start=params[:start].to_i
	    ending=params[:end].to_i
		@keyclientorder = Keyclientorder.find(params[:id])
		@orders=@keyclientorder.orders.order("customer_postcode").limit(ending-start+1)
		@orders.each_with_index do |order,i|
			order.tracking_number=(start+i).to_s
			order.status='printed'
			order.user_id=current_user.id
			order.transport_type=@transport_type
			order.save
		end
		flash[:alert] = "正在打印"
	end

	def webtracking
		@ids=params[:ids]
		@flag=params[:flag]
	end

	def webtrackingnum
		@keycorder =nil
		if params[:flag]=='filter'
			time = Time.new
			batch_id = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
			@keycorder = Keyclientorder.create(keyclient_name: "auto",unit_id: current_user.unit_id,storage_id: session[:current_storage].id,batch_id: batch_id,user: current_user,status: "printed")
        end
		@transport_type=params[:transport_type]
		start=params[:start].to_i
	    ending=params[:end].to_i
		@ids=params[:id].split(",").map(&:to_i)
		(start..ending).each_with_index do |num,i|
			order = Order.find(@ids[i])
			order.tracking_number=num.to_s
			order.status='printed'
			order.user_id=current_user.id
			order.transport_type=@transport_type
			if params[:flag]=='filter'
				order.keyclientorder_id=@keycorder.id
			end
			order.save
		end
		flash[:alert] = "正在打印"
	end

end
