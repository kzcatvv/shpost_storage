require 'spec_helper'

describe BcmInterfaceController do
	describe "access without login" do
		context "commodity_enter" do
			before :each do
				@format = 'JSON'
                @business = Business.find_by(no: '0001')
                @plaintext={"transSn"=>"201211051643571000316", "goodsInfoS"=>[{"vendorId"=>"00001017", "prodId"=>"10000079", "prodName"=>"第一个商品", "prodSpecs"=>"第一个商品的商品规格"}]}.to_json
                @sign = Digest::MD5.base64digest(@plaintext + @business.secret_key)
            end

            it "should change Thirdpartcode " do
                expect{get :commodity_enter, format: @format, plaintext: @plaintext, sign: @sign}.to change(Relationship, :count).by(1)
            end

            it "should success " do
                get :commodity_enter, format: @format, plaintext: @plaintext, sign: @sign
                response_hash = ActiveSupport::JSON.decode(response.body)
                # expect(response.body).to eq '{"FLAG":"success"}'
                expect(response_hash["returnFlag"]).to eq "00"
            end
        end


        context "order_enter" do
            before :each do
                @format = 'JSON'
                @business = Business.find_by(no: '0001')
                @plaintext={"orderId"=>"201403193000012344","transSn"=>"201211051643571000316","vendorId"=>"00001017","name"=>"张三","mobile"=>"15801001236","telephone"=>"021-38769888","address"=>"上海,上海,浦东,松涛路88号","zip"=>"200120","orderMem"=>"请尽快配送","prodS"=>[{"clubdeliverNo"=>"111111","prodId"=>"10000079","prodSpec"=>"第一个商品的商品规格","prodName"=>"第一个商品","prodAmt"=>"1"}]}.to_json
                @sign = Digest::MD5.base64digest(@plaintext + @business.secret_key)
            end
            it "should change Order " do
                expect{get :order_enter, format: @format, plaintext: @plaintext, sign: @sign}.to change(Order, :count).by(1)
            end

            it "should change OrderDetail " do
                expect{get :order_enter, format: @format, plaintext: @plaintext, sign: @sign}.to change(OrderDetail, :count).by(1)
            end

            it "should success " do
                get :order_enter, format: @format, plaintext: @plaintext, sign: @sign
                response_hash = ActiveSupport::JSON.decode(response.body)
                expect(response_hash["returnFlag"]).to eq "00"
            end
        end

        context "stock_query" do
            before :each do
                @format = 'JSON'
                @business = Business.find_by(no: '0001')
                @plaintext={"transSn"=>"201211051643571000316","goodsInfoS"=>[{"serNo"=>"20121105164357100031601","vendorId"=>"G001","prodId"=>"000","prodName"=>"商品1","prodSpecs"=>"Sname1"}]}.to_json
                @sign = Digest::MD5.base64digest(@plaintext + @business.secret_key)
            end
            it "should success " do
                get :stock_query, format: @format, plaintext: @plaintext,sign: @sign
                response_hash = ActiveSupport::JSON.decode(response.body)
                expect(response_hash["stock"]).not_to be_nil
                expect(response_hash["stock"].size).not_to be_nil
            end
        end

        context "order_query" do
            it "should success " do
                get :order_query
                expect(assigns(:totalno)).not_to be_nil
            end
        end

    end
end
