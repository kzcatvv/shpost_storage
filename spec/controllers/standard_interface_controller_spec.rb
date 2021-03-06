require 'spec_helper' 

describe StandardInterfaceController do
  describe "access without login" do
    # context "commodity_enter" do
    #   before :each do 
    #     @format = 'JSON'
        
    #     @business = Business.find_by(no: '0001')
    #     #@unit = Unit.find_by(no: '0001')
    #     @context = {'SKU' => '000000001', 'NAME' => 'Iphone5S', 'SUPPLIER' => 'Apple', 'SPEC' => 'WIFI 32G', 'DESC' => 'Apple Iphone5S WIFI 32g'}.to_json
    #     @sign = Digest::MD5.base64digest(@context + @business.secret_key)
    #   end

    #   it "should change Relationship " do
    #     expect{get :commodity_enter, format: @format, context: @context, business: '0001', unit: '0001', sign: @sign}.to change(Relationship, :count).by(1)

    #   end

    #   it "should success " do
    #     get :commodity_enter, format: @format, context: @context, business: '0001', unit: '0001', sign: @sign
    #     response_hash = ActiveSupport::JSON.decode(response.body)
    #     # expect(response.body).to eq '{"FLAG":"success"}'
    #     expect(response_hash["FLAG"]).to eq "success"
    #   end
    # end

    context "order_enter" do
      before :each do 
        @format = 'JSON'
        
        @business = Business.find_by(no: '0000000001')
        #@unit = Unit.find_by(no: '0001')
        @context = {'ORDER_ID' => 'W00000000001', 'TRANS_SN' => 'T00000000001', 'DATE' => '20140421123020', 'API_KEY' => '99999', 'EXPS' => 'gjxb', 'EXPS_GUID' => '23231232', 'EXPS_REG' => '0', 'EXPS_TYPE' =>'3', 'CUST_NAME' => 'test cust', 'CUST_UNIT' => '', 'COUNTRY' => 'Russia', 'PROVINCE' => '', 'CITY' => 'Moscow', 'ADDR' => '黑龙江省哈尔滨市特例县200弄20号12室' , 'TEL' => '18622673213', 'ZIP' => '2032322', 'LOCAL_NAME' => 'Влади́мир Влади́мирович Пу́тин', 'LOCAL_COUNTRY' => 'Российская', 'LOCAL_PROVINCE' => '', 'LOCAL_ADDR' => '', 'LOCAL_CITY' => '', 'DESC' => 'NO' , 'SEND_NAME' => 'Kiat.mao', 'SEND_PROVINCE' => 'Shanghai', 'SEND_CITY' => 'Shanghai', 'SEND_ADDR' => 'BaoChun Road No.178', 'SEND_ZIP' => '200051', 'SEND_MOBILE' => '12345678', 'TOTAL_WEIGHT' => '2.3', 'ORDER_DETAILS' => [{'DELIVER_NO' => '000001', 'BUSINESS_SKU' => '000000001', 'QTY' => '1', 'NAME' => 'Shirt', 'FROM_COUNTRY' => 'China', 'PRICE' => '10.02'}, {'DELIVER_NO' => '000002', 'BUSINESS_SKU' => '000000002', 'QTY' => '2',  'NAME' => 'Jeans', 'FROM_COUNTRY' => 'China', 'PRICE' => '23.50'}]}.to_json

        @sign = Digest::MD5.hexdigest("#{@context}#{@business.secret_key}")
      end

      it "should change Order " do
        expect{post :order_enter, format: @format, context: @context, business: '0000000001', unit: '00002', sign: @sign}.to change(Order, :count).by(1)
      end

      it "should change OrderDetail " do
        expect{post :order_enter, format: @format, context: @context, business: '0000000001', unit: '00002', sign: @sign}.to change(OrderDetail, :count).by(2)
      end

      it "should success " do
        get :order_enter, format: @format, context: @context, business: '0000000001', unit: '00002', sign: @sign


        response_hash = ActiveSupport::JSON.decode(response.body)
        # expect(response.body).to eq '{"FLAG":"success"}'
        expect(response_hash["FLAG"]).to eq "success"
      end
    end

    # context "order_query" do
    #   before :each do 
    #     @format = 'JSON'
        
    #     @business = Business.find_by(no: '0001')
    #     #@unit = Unit.find_by(no: '0001')
    #     @context = {'ORDER_ID' => '00000000000'}.to_json
    #     @sign = Digest::MD5.base64digest(@context + @business.secret_key)
    #   end

    #   it "should success " do
    #     get :order_query, format: @format, context: @context, business: '0001', unit: '0001', sign: @sign
    #     response_hash = ActiveSupport::JSON.decode(response.body)
    #     # expect(response.body).to eq '{"FLAG":"success"}'
    #     expect(response_hash["FLAG"]).to eq "success"
    #     expect(response_hash["STATUS"]).not_to be_nil
    #   end
    # end

    # context "stock_query" do
    #   before :each do 
    #     @format = 'JSON'
        
    #     @business = Business.find_by(no: '0001')
    #     #@unit = Unit.find_by(no: '0001')
    #     @context = {'QUERY_ARRAY' => [{'SKU' => '000000002'},{'SKU' => '000000001'}]}.to_json
    #     @sign = Digest::MD5.base64digest(@context + @business.secret_key)
    #   end

    #   it "should success " do
    #     get :stock_query, format: @format, context: @context, business: '0001', unit: '0001', sign: @sign
    #     response_hash = ActiveSupport::JSON.decode(response.body)
    #     # expect(response.body).to eq '{"FLAG":"success"}'
       
    #     expect(response_hash["FLAG"]).to eq "success"
    #     expect(response_hash["STOCK_ARRAY"]).not_to be_nil
    #     expect(response_hash["STOCK_ARRAY"].size).to eq 2
    #   end
    # end
  end
end
