class BcmInterfaceController < ApplicationController
	skip_before_filter :authenticate_user!
	before_filter :verify_params
	before_filter :verify_sign

    def commodity_enter
    # supplier_no = @context_hash["SUPPLIER"]
    sku = @context_hash["SKU"]
    return render json: error_builder('0005', '商品sku编码为空') if sku.blank?
    # spec = @context_hash["SPEC"]
    name = @context_hash["NAME"]
    return render json: error_builder('0005', '商品名称为空') if name.blank?

    # desc = @context_hash["DESC"]

    thirdpartcode = StandardInterface.commodity_enter(@context_hash, @business, @unit)

    if !thirdpartcode.blank?
      render json: success_builder({"SKU" => thirdpartcode.specification.sku })
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
			@context_hash = ActiveSupport::JSON.decode(@context)
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
