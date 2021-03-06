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

describe PurchaseDetailsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BuniessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("user/admin access to purchase_details") do
    describe "GET index" do
      it "assigns all purchase_details as @purchase_details" do
        get :index
        expect(assigns(:purchase_details)).to eq([@purchase_detail1, @purchase_detail2, @purchase_detail3])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested purchase_detail as @purchase_detail" do
        get :show, id: @purchase_detail1
        expect(assigns(:purchase_detail)).to eq(@purchase_detail1)
      end

      it "renders the show view" do
        get :show, id: @purchase_detail1
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new purchase_detail as @purchase_detail" do
        get :new
        expect(assigns(:purchase_detail)).to be_a_new(PurchaseDetail)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested purchase_detail as @purchase_detail" do
        get :edit, id: @purchase_detail1
        expect(assigns(:purchase_detail)).to eq(@purchase_detail1)
      end

      it "renders the edit view" do
        get :edit, id: @purchase_detail1
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new Purchase" do
            expect { post :create, purchase_detail: FactoryGirl.attributes_for(:purchase_detail) }.to change(PurchaseDetail, :count).by(1)
        end

        it "assigns a newly created purchase_detail as @purchase_detail" do
          post :create, purchase_detail: FactoryGirl.attributes_for(:purchase_detail)
          expect(assigns(:purchase_detail)).to be_a(PurchaseDetail)
          expect(assigns(:purchase_detail)).to be_persisted
        end

        it "redirects to the created purchase_detail" do
          post :create, purchase_detail: FactoryGirl.attributes_for(:purchase_detail)
          expect(response).to redirect_to(PurchaseDetail.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved purchase_detail as @purchase_detail" do
          expect{post :create, purchase_detail: FactoryGirl.attributes_for(:invalid_purchase_detail)}.to_not change(PurchaseDetail, :count)
        end

        it "re-renders the 'new' template" do
          post :create, purchase_detail: FactoryGirl.attributes_for(:invalid_purchase_detail)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @purchase_detail" do
          patch :update, id: @purchase_detail1, purchase_detail: FactoryGirl.attributes_for(:update_no)
          expect(assigns(:purchase_detail)).to eq @purchase_detail1
        end

        it "changes @purchase_detail's attributes" do
          patch :update, id: @purchase_detail1, purchase_detail: FactoryGirl.attributes_for(:update_purchase_detail)
          @purchase_detail1.reload
          expect(@purchase_detail1.name).to eq("stamp")
          expect(@purchase_detail1.amount).to eq(200)
          expect(@purchase_detail1.sum).to eq(200.1)
        end

        it "redirects to the purchase_detail" do
          patch :update, id: @purchase_detail1, purchase_detail: FactoryGirl.attributes_for(:update_purchase_detail)
          expect(response).to redirect_to @purchase_detail1
        end
      end

      context "with invalid params" do
        it "does not change the purchase_detail's attributes" do
          put :update, id: @purchase_detail1, purchase_detail: FactoryGirl.attributes_for(:invalid_purchase_detail)
          @purchase_detail1.reload
          expect(@purchase_detail1.sum).to eq(100.1)
          expect(@purchase_detail1.amount).to_not eq(0)
        end

        it "re-renders the 'edit' template" do
          put :update, id: @purchase_detail1, purchase_detail: FactoryGirl.attributes_for(:invalid_purchase_detail)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested purchase_detail" do
        expect {
          delete :destroy, id: @purchase_detail1
        }.to change(PurchaseDetail, :count).by(-1)
      end

      it "redirects to the purchase_details list" do
        delete :destroy, id: @purchase_detail1
        expect(response).to redirect_to(purchase_details_url)
      end

    end
  end

  shared_examples("guest access to purchase_details") do
    describe "GET index" do
      it "should login" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET show" do
      it "should login" do
        get :show, id: @purchase_detail1
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
        get :edit, id: @purchase_detail1
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "POST create" do
        it "should login" do
          post :create, purchase_detail: FactoryGirl.attributes_for(:purchase_detail)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "PATCH update" do
        it "should login" do
          patch :update, id: @purchase_detail1, purchase_detail: FactoryGirl.attributes_for(:purchase_detail)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "DELETE destroy" do
      it "should login" do
        delete :destroy, id: @purchase_detail1
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "admin access" do
    before :each do 
      #FactoryGirl.create(:purchase_detail)
      FactoryGirl.create(:superadmin)

      @superadmin = User.find 1
      @purchase_detail1 = FactoryGirl.create(:purchase_detail)
      @purchase_detail2 = FactoryGirl.create(:purchase_detail)
      @purchase_detail3 = FactoryGirl.create(:purchase_detail)
      sign_in @superadmin
    end

    it_behaves_like "user/admin access to purchase_details"
    
  end

  describe "guess access" do
    before :each do 
      #FactoryGirl.create(:purchase_detail)
      @purchase_detail1 = FactoryGirl.create(:purchase_detail)
      @purchase_detail2 = FactoryGirl.create(:purchase_detail)
      @purchase_detail3 = FactoryGirl.create(:purchase_detail)
    end

    it_behaves_like "guest access to purchase_details"
  end
end
