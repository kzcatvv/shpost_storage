require 'spec_helper'

describe BcmInterfaceController do
	describe "access without login" do
		context "commodity_enter" do
			before :each do
				@format = 'JSON'
                @business = Business.find_by(no: '0003')
                #@unit = Unit.find_by(no: '0001')
                plaintext={"transSn"=>"201211051643571000316", "goodsInfoS"=>[{"vendorId"=>"00001017", "prodId"=>"10000079", "prodName"=>"第一个商品", "prodSpecs"=>"第一个商品的商品规格"}]}
                context_hash=Hash.new
    		    context_hash["SUPPLIER"]=plaintext["goodsInfoS"]["vendorId"]
    		    context_hash["SKU"]=plaintext["goodsInfoS"]["prodId"]
    		    context_hash["NAME"]=plaintext["goodsInfoS"]["prodName"]
    		    context_hash["SPEC"]=plaintext["goodsInfoS"]["prodSpecs"]
    		    context_hash["DESC"]=""
                @context = context_hash.to_json
                @sign = Digest::MD5.base64digest(@context + @business.secret_key)
            end

            it "should change Thirdpartcode " do
                expect{get :commodity_enter, format: @format, context: @context, business: '0003', unit: '0001', sign: @sign}.to change(Thirdpartcode, :count).by(1)
            end

            it "should success " do
                get :commodity_enter, format: @format, context: @context, business: '0003', unit: '0001', sign: @sign
                response_hash = ActiveSupport::JSON.decode(response.body)
                # expect(response.body).to eq '{"FLAG":"success"}'
                expect(response_hash["returnFlag"]).to eq "00"
            end
        end
    end
end
