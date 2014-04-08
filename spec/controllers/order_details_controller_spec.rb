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

describe OrderDetailsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order_detail to pass any filters (e.g. authentication) defined in
  # BuniessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("user/admin access to order_details") do
    describe "GET index" do
      it "assigns all order_details as @order_details" do
        get :index
        expect(assigns(:order_details)).to eq([@order_detail1, @order_detail2, @order_detail3])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested order_detail as @order_detail" do
        get :show, id: @order_detail1
        expect(assigns(:order_detail)).to eq(@order_detail1)
      end

      it "renders the show view" do
        get :show, id: @order_detail1
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new order_detail as @order_detail" do
        get :new
        expect(assigns(:order_detail)).to be_a_new(OrderDetail)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested order_detail as @order_detail" do
        get :edit, id: @order_detail1
        expect(assigns(:order_detail)).to eq(@order_detail1)
      end

      it "renders the edit view" do
        get :edit, id: @order_detail1
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new OrderDetail" do
            expect { post :create, order_detail: FactoryGirl.attributes_for(:order_detail) }.to change(OrderDetail, :count).by(1)
        end

        it "assigns a newly created order_detail as @order_detail" do
          post :create, order_detail: FactoryGirl.attributes_for(:order_detail)
          expect(assigns(:order_detail)).to be_a(OrderDetail)
          expect(assigns(:order_detail)).to be_persisted
        end

        it "redirects to the created order_detail" do
          post :create, order_detail: FactoryGirl.attributes_for(:order_detail)
          expect(response).to redirect_to(OrderDetail.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved order_detail as @order_detail" do
          expect{post :create, order_detail: FactoryGirl.attributes_for(:invalid_order_detail)}.to_not change(OrderDetail, :count)
        end

        it "re-renders the 'new' template" do
          post :create, order_detail: FactoryGirl.attributes_for(:invalid_order_detail)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @order_detail" do
          patch :update, id: @order_detail1, order_detail: FactoryGirl.attributes_for(:update_order_detail)
          expect(assigns(:order_detail)).to eq @order_detail1
        end

        it "changes @order_detail's attributes" do
          patch :update, id: @order_detail1, order_detail: FactoryGirl.attributes_for(:update_order_detail)
          @order_detail1.reload
          expect(@order_detail1.name).to eq("20140401001")
          expect(@order_detail1.amount).to eq(200)
          expect(@order_detail1.price).to eq(200.1)
        end

        it "redirects to the order_detail" do
          patch :update, id: @order_detail1, order_detail: FactoryGirl.attributes_for(:update_order_detail)
          expect(response).to redirect_to @order_detail1
        end
      end

      context "with invalid params" do
        it "does not change the order_detail's attributes" do
          put :update, id: @order_detail1, order_detail: FactoryGirl.attributes_for(:invalid_order_detail)
          @order_detail1.reload
          expect(@order_detail1.price).to eq(1.5)
          expect(@order_detail1.amount).to_not eq(0)
        end

        it "re-renders the 'edit' template" do
          put :update, id: @order_detail1, order_detail: FactoryGirl.attributes_for(:invalid_order_detail)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested order_detail" do
        expect {
          delete :destroy, id: @order_detail1
        }.to change(OrderDetail, :count).by(-1)
      end

      it "redirects to the order_details list" do
        delete :destroy, id: @order_detail1
        expect(response).to redirect_to(order_details_url)
      end

    end
  end

  shared_examples("guest access to order_details") do
    describe "GET index" do
      it "should login" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET show" do
      it "should login" do
        get :show, id: @order_detail1
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
        get :edit, id: @order_detail1
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "POST create" do
        it "should login" do
          post :create, order_detail: FactoryGirl.attributes_for(:order_detail)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "PATCH update" do
        it "should login" do
          patch :update, id: @order_detail1, order_detail: FactoryGirl.attributes_for(:order_detail)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "DELETE destroy" do
      it "should login" do
        delete :destroy, id: @order_detail1
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "admin access" do
    before :each do 
      #FactoryGirl.create(:order_detail)
      FactoryGirl.create(:superadmin)

      @superadmin = User.find 1
      @order_detail1 = FactoryGirl.create(:order_detail)
      @order_detail2 = FactoryGirl.create(:order_detail)
      @order_detail3 = FactoryGirl.create(:order_detail)
      sign_in @superadmin
    end

    it_behaves_like "user/admin access to order_details"
    
  end

  describe "guess access" do
    before :each do 
      #FactoryGirl.create(:order_detail)
      @order_detail1 = FactoryGirl.create(:order_detail)
      @order_detail2 = FactoryGirl.create(:order_detail)
      @order_detail3 = FactoryGirl.create(:order_detail)
    end

    it_behaves_like "guest access to order_details"
  end
end