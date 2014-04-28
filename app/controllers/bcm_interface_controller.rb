class BcmInterfaceController < ApplicationController
	skip_before_filter :authenticate_user!
	before_filter :verify_params
	before_filter :verify_sign

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

		@business = Business.find_by(no: '0003')
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
