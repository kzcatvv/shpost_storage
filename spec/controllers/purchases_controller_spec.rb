require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe PurchasesController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BuniessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("user/admin access to purchases") do
    describe "GET index" do
      it "assigns all purchases as @purchases" do
        get :index
        expect(assigns(:purchases)).to eq([@purchase1, @purchase2, @purchase3])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested purchase as @purchase" do
        get :show, id: @purchase1
        expect(assigns(:purchase)).to eq(@purchase1)
      end

      it "renders the show view" do
        get :show, id: @purchase1
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new purchase as @purchase" do
        get :new
        expect(assigns(:purchase)).to be_a_new(Purchase)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested purchase as @purchase" do
        get :edit, id: @purchase1
        expect(assigns(:purchase)).to eq(@purchase1)
      end

      it "renders the edit view" do
        get :edit, id: @purchase1
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new Purchase" do
            expect { post :create, purchase: FactoryGirl.attributes_for(:purchase) }.to change(Purchase, :count).by(1)
        end

        it "assigns a newly created purchase as @purchase" do
          post :create, purchase: FactoryGirl.attributes_for(:purchase)
          expect(assigns(:purchase)).to be_a(Purchase)
          expect(assigns(:purchase)).to be_persisted
        end

        it "redirects to the created purchase" do
          post :create, purchase: FactoryGirl.attributes_for(:purchase)
          expect(response).to redirect_to(Purchase.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved purchase as @purchase" do
          expect{post :create, purchase: FactoryGirl.attributes_for(:invalid_purchase)}.to_not change(Business, :count)
        end

        it "re-renders the 'new' template" do
          post :create, purchase: FactoryGirl.attributes_for(:invalid_purchase)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @purchase" do
          patch :update, id: @purchase1, purchase: FactoryGirl.attributes_for(:update_no)
          expect(assigns(:purchase)).to eq @purchase1
        end

        it "changes @purchase's attributes" do
          patch :update, id: @purchase1, purchase: FactoryGirl.attributes_for(:update_no)
          @purchase1.reload
          expect(@purchase1.no).to eq("20140401001")
          expect(@purchase1.amount).to eq(200)
          expect(@purchase1.sum).to eq(200.1)
        end

        it "redirects to the purchase" do
          patch :update, id: @purchase1, purchase: FactoryGirl.attributes_for(:update_no)
          expect(response).to redirect_to @purchase1
        end
      end

      context "with invalid params" do
        it "does not change the purchase's attributes" do
          patch :update, id: @purchase1, purchase: FactoryGirl.attributes_for(:invalid_purchase)
          @purchase1.reload
          expect(@purchase1.sum).to eq(100.1)
          expect(@purchase1.amount).to_not eq(0)
        end

        it "re-renders the 'edit' template" do
          patch :update, id: @purchase1, purchase: FactoryGirl.attributes_for(:invalid_purchase)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested purchase" do
        expect {
          delete :destroy, id: @purchase1
        }.to change(Purchase, :count).by(-1)
      end

      it "redirects to the purchases list" do
        delete :destroy, id: @purchase1
        expect(response).to redirect_to(purchases_url)
      end

    end

    #Kiat-mao
    describe "Stock in" do
      it "stock_in the requested purchase" do
        expect {
          patch :stock_in, id: @purchase1
        }.to change(StockLog, :count)
      end

      it "assigns newly stock_logs belongs_to @purchase1" do
        patch :stock_in, id: @purchase1
        assigns(:stock_logs).each do |x|
          expect(x.object_class).to eq("PurchaseDetail")
          # expect(x.object_primary_key).to eq(@purchase1.id)
        end
      end

      it "assigns newly stock_logs is vaild" do
        patch :stock_in, id: @purchase1
        assigns(:stock_logs).each do |x|
          expect(x.status).to eq(StockLog::STATUS[:waiting])
          expect(x.operation).to eq(StockLog::OPERATION[:purchase_stock_in])
          expect(x.operation_type).to eq(StockLog::OPERATION_TYPE[:in])
        end
      end

      it "assigns newly stock_logs with stock belongs_to specification that purchase include" do
        patch :stock_in, id: @purchase1
        assigns(:stock_logs).each do |x|
          expect(x.stock).not_to be_blank 
          expect(@purchase1.purchase_details.map{|x| x.specification}).to include(x.stock.specification)
        end
      end

      it "assigns newly stock_logs with stock belongs_to specifications that purchase include" do
        patch :stock_in, id: @purchase1
        assigns(:stock_logs).each do |x|
          expect(x.stock).not_to be_blank 
          expect(@purchase1.purchase_details.map{|x| x.specification}).to include(x.stock.specification)
        end
      end

      it "redirects to the stock_in list" do
        patch :stock_in, id: @purchase1
        expect(response).to render_template("stock_in")
      end
    end
  end

  shared_examples("guest access to purchases") do
    describe "GET index" do
      it "should login" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET show" do
      it "should login" do
        get :show, id: @purchase1
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET new" do
      it "should login" do
        get :new
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET edit" do
      it "should login" do
        get :edit, id: @purchase1
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "POST create" do
        it "should login" do
          post :create, purchase: FactoryGirl.attributes_for(:purchase)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "PATCH update" do
        it "should login" do
          patch :update, id: @purchase1, purchase: FactoryGirl.attributes_for(:purchase)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "DELETE destroy" do
      it "should login" do
        delete :destroy, id: @purchase1
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "admin access" do
    before :each do 
      #FactoryGirl.create(:purchase)
      FactoryGirl.create(:superadmin)

      @superadmin = User.find 1
      @purchase1 = FactoryGirl.create(:purchase)
      @purchase_detail1 = FactoryGirl.create(:purchase_detail)
      @purchase_detail2 = FactoryGirl.create(:purchase_detail, specification_id: 2)
      @purchase2 = FactoryGirl.create(:purchase)
      @purchase3 = FactoryGirl.create(:purchase)
      sign_in @superadmin
    end

    it_behaves_like "user/admin access to purchases"
    
  end

  describe "guess access" do
    before :each do 
      #FactoryGirl.create(:purchase)
      @purchase1 = FactoryGirl.create(:purchase)
      @purchase2 = FactoryGirl.create(:purchase)
      @purchase3 = FactoryGirl.create(:purchase)
    end

    it_behaves_like "guest access to purchases"
  end
end
