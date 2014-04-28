class BcmInterfaceController < ApplicationController
	skip_before_filter :authenticate_user!
	before_filter :verify_params, :only => [ :commodity_enter, :order_enter, :stock_query]
	before_filter :verify_sign, :only => [ :commodity_enter, :order_enter, :stock_query]

    def commodity_enter

    	@plaintext["goodsInfoS"].each do |goodsInfo|
    		context_hash=Hash.new
    		context_hash["SUPPLIER"]=goodsInfo["vendorId"]
    		context_hash["SKU"]=goodsInfo["prodId"]
    		context_hash["NAME"]=goodsInfo["prodName"]
    		context_hash["SPEC"]=goodsInfo["prodSpecs"]
    		context_hash["DESC"]=""

    		sku = context_hash["SKU"]
    		return render json: error_builder('0005', '商品sku编码为空') if sku.blank?

    		name = context_hash["NAME"]
    		return render json: error_builder('0005', '商品名称为空') if name.blank?

    		thirdpartcode = StandardInterface.commodity_enter(context_hash, @business, @unit)
    		if !thirdpartcode.blank?
    			render json: success_builder({"SKU" => thirdpartcode.specification.sku })
    		else
    			render json: error_builder('9999')
    		end
    	end
    end

    def order_enter
    	context_hash=Hash.new
    	context_hash["ORDER_ID"]=@plaintext["orderId"]
    	context_hash["TRANS_SN"]=@plaintext["transSN"]
    	context_hash["DATE"]=""
    	context_hash["EXPS"]=""
    	context_hash["CUST_NAME"]=@plaintext["name"]
    	context_hash["PROVINCE"],context_hash["CITY"],context_hash["COUNTY"]=@plaintext["address"].split(",")
    	context_hash["MOBILE"]=@plaintext["mobile"]
    	context_hash["TEL"]=@plaintext["mobile"]
    	context_hash["ADDR"]=@plaintext["address"]
    	context_hash["zip"]=@plaintext["mobile"]
    	context_hash["DESC"]=@plaintext["orderMem"]
    	context_hash["CUST_UNIT"]=""
    	context_hash["QTY_SUM"]=""
    	context_hash["AMT_SUM"]=""
    	context_hash["EXPS_SUM"]=""
    	context_hash["SEND_ADDR"]=""
    	context_hash["SEND_NAME"]=""
    	context_hash["SEND_ZIP"]=""
    	context_hash["SEND_MOBILE"]=""

        context_hash["ORDER_DETAILS"]=Array.new
    	@plaintext["prodS"].each_with_index do |prod,i|
    		context_hash["ORDER_DETAILS"][i]=Hash.new
            context_hash["ORDER_DETAILS"][i]["DELIVER_NO"]=prod["clubdeliverNo"]
            context_hash["ORDER_DETAILS"][i]["SUPPLIER"]=@plaintext["vendorId"]
            context_hash["ORDER_DETAILS"][i]["SKU"]=prod["prodId"]
            context_hash["ORDER_DETAILS"][i]["SPEC"]=prod["prodSpec"]
            context_hash["ORDER_DETAILS"][i]["DESC"]=""
            context_hash["ORDER_DETAILS"][i]["NAME"]=prod["prodName"]
            context_hash["ORDER_DETAILS"][i]["QTY"]=prod["prodAmt"]
            context_hash["ORDER_DETAILS"][i]["PRICE"]=""
            context_hash["ORDER_DETAILS"][i]["AMT"]=""
    	end
        order_id = context_hash['ORDER_ID']
        return render json: error_builder('0005', '订单号为空') if order_id.blank?
        trans_sn = context_hash['TRANS_SN']
        return render json: error_builder('0005', '交易流水号为空') if trans_sn.blank?
        cust_name = context_hash['CUST_NAME']
        return render json: error_builder('0005', '收件人姓名为空') if cust_name.blank?
        addr = context_hash['ADDR']
        return render json: error_builder('0005', '收货人地址为空') if addr.blank?

        order_details = context_hash['ORDER_DETAILS']
        return render json: error_builder('0005', '商品列表为空') if order_details.blank?

        order = StandardInterface.order_enter(context_hash, @business, @unit)

        if !order.blank?
            render json: success_builder({'ORDER_NO' => order.no })
        else
            render json: error_builder('9999')
        end
    end

    def stock_query
        context_hash=Hash.new
        context_hash["QUERY_ARRY"]=Array.new
        @plaintext["goodsInfoS"].each_with_index do |goodsInfo,i|
            context_hash["QUERY_ARRY"][i]=Hash.new
            context_hash["QUERY_ARRY"][i]["SUPPLIER"]=goodsInfo["vendorId"]
            context_hash["QUERY_ARRY"][i]["SKU"]=goodsInfo["prodId"]
            context_hash["QUERY_ARRY"][i]["SPEC"]=goodsInfo["prodSpecs"]
        end
        stock_array = StandardInterface.stock_query(context_hash, @business, @unit)

        stock_return=Hash.new
        stock_return["transSn"]=@plaintext["transSn"]
        stock_return["stock"]=Array.new
        @plaintext["goodsInfoS"].each_with_index do |goodsInfo,i|
            stock_return["stock"][i]=Hash.new
            stock_return["stock"][i]["serNo"]=goodsInfo["serNo"]
            stock_return["stock"][i]["storeAmt"]=stock_array[i]["AMT"]
        end
        stock_return["sign"]=@sign
        render json: stock_return.to_json
    end

    def order_query
        array = BcmInterface.notice_array(StorageConfig.config["business"]['jh_id'], StorageConfig.config["unit"]['zb_id'])
        if !array.blank?
            plaintext=Hash.new
            plaintext["goodsInfoS"]=Array.new
            count=0
            array.each do |order_notice|
                order=Order.find(order_notice.id)
                order.order_details.each do |detail|
                    plaintext["goodsInfoS"][count]=Hash.new
                    plaintext["goodsInfoS"][count]["transSn"]=order.business_trans_no
                    plaintext["goodsInfoS"][count]["clubdeliverNo"]=detail.business_deliver_no
                    plaintext["goodsInfoS"][count]["deliverState"]=order_notice.deliver_notices[0].send_type
                    plaintext["goodsInfoS"][count]["deliverNotes"]=order.transport_type
                    plaintext["goodsInfoS"][count]["deliverNo"]=order.tracking_number
                end
                count=count+1
            end
            totalno=count
            sign=Business.find(StorageConfig.config["business"]['jh_id']).secret_key
        end
    end

	private
	def verify_params
		@format = params[:format]
		return render json: error_builder('0002') if !@format.eql? 'JSON'

		@context = params[:plaintext]
		begin
			@plaintext = ActiveSupport::JSON.decode(@context)
		rescue ActiveSupport::JSON.parse_error
			return render json: error_builder('0002')
		end

		@business = Business.find(StorageConfig.config["business"]['jh_id'])
        @unit = Unit.find(StorageConfig.config["unit"]['zb_id'])
	end

    def verify_sign
    	@sign = params[:sign]
    	render json: error_builder('0001') if !@sign.eql? Digest::MD5.base64digest(@context + @business.secret_key)
    end

    def error_builder(code, msg = nil)
        {'returnFlag' => '01', 'ReturnCode' => msg.nil? ? I18n.t("bcm_interface.error.#{code}") : I18n.t("bcm_interface.error.#{code}") + ':' + msg }.to_json
    end

    def success_builder
        success = {'returnFlag' => '00'}
    end
end
