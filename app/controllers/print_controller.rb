class PrintController < ApplicationController
	layout false

	def tracking
		@order = Order.find(params[:id])
	end

	def trackingnum
		order = Order.find(params[:id])
		order.tracking_number=params[:num]
		order.status='printed'
		order.save
		flash[:alert] = "正在打印"
	end

	def keytracking
		@keyclientorder = Keyclientorder.find(params[:id])
	end

	def keytrackingnum
		start=params[:start].to_i
	    ending=params[:end].to_i
		@keyclientorder = Keyclientorder.find(params[:id])
		@orders=@keyclientorder.orders.limit(ending-start+1)
		@orders.each_with_index do |order,i|
			order.tracking_number=(start+i).to_s
			order.status='printed'
			order.save
		end
		flash[:alert] = "正在打印"
	end

	def webtracking
		@ids=params[:ids]
	end

	def webtrackingnum
		start=params[:start].to_i
	    ending=params[:end].to_i
		@ids=params[:id].split(",").map(&:to_i)
		(start..ending).each_with_index do |num,i|
			order = Order.find(@ids[i])
			order.tracking_number=num.to_s
			order.status='printed'
			order.save
		end
		flash[:alert] = "正在打印"
	end

end
