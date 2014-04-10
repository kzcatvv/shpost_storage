class PrintController < ApplicationController
	layout false
	def tracking
		@order = Order.find(params[:id])
	end

	def trackingnum
		order = Order.find(params[:id])
		order.tracking_number=params[:num]
		order.save
		flash[:alert] = "正在打印"
	end
end
