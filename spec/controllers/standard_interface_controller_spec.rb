require 'spec_helper'

describe StandardInterfaceController do
  describe "access without login" do
    context "commodity_enter" do
      before :each do 
        @format = 'JSON'
        
        @business = Business.find_by(no: '0001')
        #@unit = Unit.find_by(no: '0001')
        @context = {'SKU' => '000000001', 'NAME' => 'Iphone5S', 'SUPPLIER' => 'Apple', 'SPEC' => 'WIFI 32G', 'DESC' => 'Apple Iphone5S WIFI 32g'}.to_json
        @sign = Digest::MD5.base64digest(@context + @business.secret_key)
      end

      it "should change Thirdpartcode " do
        expect{get :commodity_enter, format: @format, context: @context, business: '0001', unit: '0001', sign: @sign}.to change(Thirdpartcode, :count).by(1)

      end

      it "should success " do
        get :commodity_enter, format: @format, context: @context, business: '0001', unit: '0001', sign: @sign
        response_hash = ActiveSupport::JSON.decode(response.body)
        # expect(response.body).to eq '{"FLAG":"success"}'
        expect(response_hash["FLAG"]).to eq "success"
      end
    end

    context "order_enter" do

    end

    context "order_query" do

    end

    context "stock_query" do
    end
  end
end
