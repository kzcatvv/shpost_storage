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

describe StocksController do

  # This should return the minimal set of attributes required to create a valid
  # Stock. As you add validations to Stock, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BuniessesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("user/admin access to stocks") do
    describe "GET index" do
      it "assigns all stocks as @stocks" do
        get :index
        expect(assigns(:stocks)).to eq([@stock, @stock2, @stock3])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested stock as @stock" do
        get :show, id: @stock
        expect(assigns(:stock)).to eq(@stock)
      end

      it "renders the show view" do
        get :show, id: @stock
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new stock as @stock" do
        get :new
        expect(assigns(:stock)).to be_a_new(Stock)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested stock as @stock" do
        get :edit, id: @stock
        expect(assigns(:stock)).to eq(@stock)
      end

      it "renders the edit view" do
        get :edit, id: @stock
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new Stock" do
            expect { post :create, stock: FactoryGirl.attributes_for(:stock) }.to change(Stock, :count).by(1)
        end

        it "assigns a newly created stock as @stock" do
          post :create, stock: FactoryGirl.attributes_for(:stock)
          expect(assigns(:stock)).to be_a(Stock)
          expect(assigns(:stock)).to be_persisted
        end

        it "redirects to the created stock" do
          post :create, stock: FactoryGirl.attributes_for(:stock)
          expect(response).to redirect_to(Stock.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved stock as @stock" do
          expect{post :create, stock: FactoryGirl.attributes_for(:invalid_without_aa_stock)}.to_not change(Stock, :count)
        end

        it "re-renders the 'new' template" do
          post :create, stock: FactoryGirl.attributes_for(:invalid_without_aa_stock)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @stock" do
          patch :update, id: @stock, stock: FactoryGirl.attributes_for(:update_stock)
          expect(assigns(:stock)).to eq @stock
        end

        it "changes @stock's attributes" do
          patch :update, id: @stock, stock: FactoryGirl.attributes_for(:update_stock)
          @stock.reload
          expect(@stock.actual_amount).to eq(40)
          expect(@stock.virtual_amount).to eq(50)
        end

        it "redirects to the stock" do
          patch :update, id: @stock, stock: FactoryGirl.attributes_for(:update_stock)
          expect(response).to redirect_to @stock
        end
      end

      context "with invalid params" do
        it "does not change the stock's attributes" do
          put :update, id: @stock, stock: FactoryGirl.attributes_for(:invalid_without_aa_stock)
          @stock.reload
          expect(@stock.actual_amount).to eq(20)
          expect(@stock.virtual_amount).to_not eq(40)
        end

        it "re-renders the 'edit' template" do
          put :update, id: @stock, stock: FactoryGirl.attributes_for(:invalid_without_aa_stock)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested stock" do
        expect {
          delete :destroy, id: @stock
        }.to change(Stock, :count).by(-1)
      end

      it "redirects to the stocks list" do
        delete :destroy, id: @stock
        expect(response).to redirect_to(stocks_url)
      end

    end
  end

  shared_examples("guest access to stocks") do
    describe "GET index" do
      it "should login" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "GET show" do
      it "should login" do
        get :show, id: @stock
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
        get :edit, id: @stock
        expect(response).to redirect_to "/users/sign_in"
      end
    end

    describe "POST create" do
        it "should login" do
          post :create, stock: FactoryGirl.attributes_for(:stock)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "PATCH update" do
        it "should login" do
          patch :update, id: @stock, stock: FactoryGirl.attributes_for(:stock)
          expect(response).to redirect_to "/users/sign_in"
        end
    end

    describe "DELETE destroy" do
      it "should login" do
        delete :destroy, id: @stock
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end

  describe "admin access" do
    before :each do 
      #FactoryGirl.create(:stock)
      FactoryGirl.create(:superadmin)

      @superadmin = User.find 1
      @stock = FactoryGirl.create(:stock)
      @stock2 = FactoryGirl.create(:stock)
      @stock3 = FactoryGirl.create(:stock)
      sign_in @superadmin
    end

    it_behaves_like "user/admin access to stocks"
    
  end

  describe "guess access" do
    before :each do 
      #FactoryGirl.create(:stock)
      @stock = FactoryGirl.create(:stock)
      @stock2 = FactoryGirl.create(:stock)
      @stock3 = FactoryGirl.create(:stock)
    end

    it_behaves_like "guest access to stocks"
  end
end
