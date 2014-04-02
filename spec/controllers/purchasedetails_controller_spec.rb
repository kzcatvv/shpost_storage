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

describe PurchasedetailsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BuniessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("user/admin access to purchasedetails") do
    describe "GET index" do
      it "assigns all purchasedetails as @purchasedetails" do
        get :index
        expect(assigns(:purchasedetails)).to eq([@purchasedetail1, @purchasedetail2, @purchasedetail3])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested purchasedetail as @purchasedetail" do
        get :show, id: @purchasedetail1
        expect(assigns(:purchasedetail)).to eq(@purchasedetail1)
      end

      it "renders the show view" do
        get :show, id: @purchasedetail1
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new purchasedetail as @purchasedetail" do
        get :new
        expect(assigns(:purchasedetail)).to be_a_new(Purchasedetail)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested purchasedetail as @purchasedetail" do
        get :edit, id: @purchasedetail1
        expect(assigns(:purchasedetail)).to eq(@purchasedetail1)
      end

      it "renders the edit view" do
        get :edit, id: @purchasedetail1
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new Purchase" do
            expect { post :create, purchasedetail: FactoryGirl.attributes_for(:purchasedetail) }.to change(Purchasedetail, :count).by(1)
        end

        it "assigns a newly created purchasedetail as @purchasedetail" do
          post :create, purchasedetail: FactoryGirl.attributes_for(:purchasedetail)
          expect(assigns(:purchasedetail)).to be_a(Purchasedetail)
          expect(assigns(:purchasedetail)).to be_persisted
        end

        it "redirects to the created purchasedetail" do
          post :create, purchasedetail: FactoryGirl.attributes_for(:purchasedetail)
          expect(response).to redirect_to(Purchasedetail.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved purchasedetail as @purchasedetail" do
          expect{post :create, purchasedetail: FactoryGirl.attributes_for(:invalid_purchasedetail)}.to_not change(Purchase, :count)
        end

        it "re-renders the 'new' template" do
          post :create, purchasedetail: FactoryGirl.attributes_for(:invalid_purchasedetail)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @purchasedetail" do
          patch :update, id: @purchasedetail1, purchasedetail: FactoryGirl.attributes_for(:update_no)
          expect(assigns(:purchasedetail)).to eq @purchasedetail1
        end

        it "changes @purchasedetail's attributes" do
          patch :update, id: @purchasedetail1, purchasedetail: FactoryGirl.attributes_for(:update_purchasedetail)
          @purchasedetail1.reload
          expect(@purchasedetail1.name).to eq("stamp")
          expect(@purchasedetail1.amount).to eq(200)
          expect(@purchasedetail1.sum).to eq(200.1)
        end

        it "redirects to the purchasedetail" do
          patch :update, id: @purchasedetail1, purchasedetail: FactoryGirl.attributes_for(:update_purchasedetail)
          expect(response).to redirect_to @purchasedetail1
        end
      end

      context "with invalid params" do
        it "does not change the purchasedetail's attributes" do
          put :update, id: @purchasedetail1, purchasedetail: FactoryGirl.attributes_for(:invalid_purchasedetail)
          @purchasedetail1.reload
          expect(@purchasedetail1.sum).to eq(100.1)
          expect(@purchasedetail1.amount).to_not eq(0)
        end

        it "re-renders the 'edit' template" do
          put :update, id: @purchasedetail1, purchasedetail: FactoryGirl.attributes_for(:invalid_purchasedetail)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested purchasedetail" do
        expect {
          delete :destroy, id: @purchasedetail1
        }.to change(Purchasedetail, :count).by(-1)
      end

      it "redirects to the purchasedetails list" do
        delete :destroy, id: @purchasedetail1
        expect(response).to redirect_to(purchasedetails_url)
      end

    end
  end

  shared_examples("guest access to purchasedetails") do
    describe "GET index" do
      it "should login" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET show" do
      it "should login" do
        get :show, id: @purchasedetail1
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
        get :edit, id: @purchasedetail1
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "POST create" do
        it "should login" do
          post :create, purchasedetail: FactoryGirl.attributes_for(:purchasedetail)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "PATCH update" do
        it "should login" do
          patch :update, id: @purchasedetail1, purchasedetail: FactoryGirl.attributes_for(:purchasedetail)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "DELETE destroy" do
      it "should login" do
        delete :destroy, id: @purchasedetail1
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "admin access" do
    before :each do 
      #FactoryGirl.create(:purchasedetail)
      FactoryGirl.create(:superadmin)

      @superadmin = User.find 1
      @purchasedetail1 = FactoryGirl.create(:purchasedetail)
      @purchasedetail2 = FactoryGirl.create(:purchasedetail)
      @purchasedetail3 = FactoryGirl.create(:purchasedetail)
      sign_in @superadmin
    end

    it_behaves_like "user/admin access to purchasedetails"
    
  end

  describe "guess access" do
    before :each do 
      #FactoryGirl.create(:purchasedetail)
      @purchasedetail1 = FactoryGirl.create(:purchasedetail)
      @purchasedetail2 = FactoryGirl.create(:purchasedetail)
      @purchasedetail3 = FactoryGirl.create(:purchasedetail)
    end

    it_behaves_like "guest access to purchasedetails"
  end
end
