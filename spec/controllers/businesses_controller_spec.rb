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

describe BusinessesController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BuniessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("user/admin access to businesses") do
    describe "GET index" do
      it "assigns all businesses as @businesses" do
        get :index
        expect(assigns(:businesses)).to eq([@business1, @business2, @business3])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested business as @business" do
        get :show, id: @business1
        expect(assigns(:business)).to eq(@business1)
      end

      it "renders the show view" do
        get :show, id: @business1
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new business as @business" do
        get :new
        expect(assigns(:business)).to be_a_new(Business)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested business as @business" do
        get :edit, id: @business1
        expect(assigns(:business)).to eq(@business1)
      end

      it "renders the edit view" do
        get :edit, id: @business1
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new Business" do
            expect { post :create, business: FactoryGirl.attributes_for(:business) }.to change(Business, :count).by(1)
        end

        it "assigns a newly created business as @business" do
          post :create, business: FactoryGirl.attributes_for(:business)
          expect(assigns(:business)).to be_a(Business)
          expect(assigns(:business)).to be_persisted
        end

        it "redirects to the created business" do
          post :create, business: FactoryGirl.attributes_for(:business)
          expect(response).to redirect_to(Business.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved business as @business" do
          expect{post :create, business: FactoryGirl.attributes_for(:invalid_business)}.to_not change(Business, :count)
        end

        it "re-renders the 'new' template" do
          post :create, business: FactoryGirl.attributes_for(:invalid_business)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @business" do
          patch :update, id: @business1, business: FactoryGirl.attributes_for(:update_business)
          expect(assigns(:business)).to eq @business1
        end

        it "changes @business's attributes" do
          patch :update, id: @business1, business: FactoryGirl.attributes_for(:update_business)
          @business1.reload
          expect(@business1.name).to eq("update_name")
          expect(@business1.email).to eq("update_business@example.com")
        end

        it "redirects to the business" do
          patch :update, id: @business1, business: FactoryGirl.attributes_for(:update_business)
          expect(response).to redirect_to @business1
        end
      end

      context "with invalid params" do
        it "does not change the business's attributes" do
          put :update, id: @business1, business: FactoryGirl.attributes_for(:invalid_business)
          @business1.reload
          expect(@business1.contactor).to eq("liuyingying")
          expect(@business1.email).to_not eq("invalid@example.com")
        end

        it "re-renders the 'edit' template" do
          put :update, id: @business1, business: FactoryGirl.attributes_for(:invalid_business)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested business" do
        expect {
          delete :destroy, id: @business1
        }.to change(Business, :count).by(-1)
      end

      it "redirects to the businesses list" do
        delete :destroy, id: @business1
        expect(response).to redirect_to(businesses_url)
      end

    end
  end

  shared_examples("guest access to businesses") do
    describe "GET index" do
      it "should login" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET show" do
      it "should login" do
        get :show, id: @business1
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
        get :edit, id: @business1
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "POST create" do
        it "should login" do
          post :create, business: FactoryGirl.attributes_for(:business)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "PATCH update" do
        it "should login" do
          patch :update, id: @business1, business: FactoryGirl.attributes_for(:business)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "DELETE destroy" do
      it "should login" do
        delete :destroy, id: @business1
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "admin access" do
    before :each do 
      #FactoryGirl.create(:business)
      FactoryGirl.create(:superadmin)

      @superadmin = User.find 1
      @business1 = FactoryGirl.create(:business)
      @business2 = FactoryGirl.create(:business)
      @business3 = FactoryGirl.create(:business)
      sign_in @superadmin
    end

    it_behaves_like "user/admin access to businesses"
    
  end

  describe "guess access" do
    before :each do 
      #FactoryGirl.create(:business)
      @business1 = FactoryGirl.create(:business)
      @business2 = FactoryGirl.create(:business)
      @business3 = FactoryGirl.create(:business)
    end

    it_behaves_like "guest access to businesses"
  end
end
