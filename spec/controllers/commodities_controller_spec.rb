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

describe CommoditiesController do

  # This should return the minimal set of attributes required to create a valid
  # Commodity. As you add validations to Commodity, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CommoditiesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  shared_examples("commodity/test to commodities") do
      
    describe "GET index" do
      # it "assigns all commodities as @commodities" do
      #   get :index
      #   expect(assigns(:commodities)).to eq([@commodity])
      # end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested commodity as @commodity" do
        get :show, id: @commodity
        expect(assigns(:commodity)).to eq(@commodity)
      end

      it "renders the show view" do
        get :show, id: @commodity
        expect(response).to render_template :show
      end
    end

    describe "GET new" do
      it "assigns a new commodity as @commodity" do
        get :new
        expect(assigns(:commodity)).to be_a_new(Commodity)
      end

      it "renders the new view" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe "GET edit" do
      it "assigns the requested commodity as @commodity" do
        get :edit, id: @commodity
        expect(assigns(:commodity)).to eq(@commodity)
      end

      it "renders the edit view" do
        get :edit, id: @commodity
        expect(response).to render_template :edit
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new commodity" do
            expect { post :create, commodity: FactoryGirl.attributes_for(:new_commodity) }.to change(Commodity, :count).by(1)
        end

        it "assigns a newly created commodity as @commodity" do
          post :create, commodity: FactoryGirl.attributes_for(:new_commodity)
          expect(assigns(:commodity)).to be_a(Commodity)
          expect(assigns(:commodity)).to be_persisted
        end

        it "redirects to the created commodity" do
          post :create, commodity: FactoryGirl.attributes_for(:new_commodity)
          expect(response).to redirect_to(Commodity.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved commodity as @commodity" do
          expect{post :create, commodity: FactoryGirl.attributes_for(:invalid_commodity)}.to_not change(Commodity, :count)
        end

        it "re-renders the 'new' template" do
          post :create, commodity: FactoryGirl.attributes_for(:invalid_commodity)
          expect(response).to render_template :new
        end
      end
    end

    describe "PATCH update" do
      context "with valid params" do
        it "locates the requested @commodity" do
          patch :update, id: @commodity, commodity: FactoryGirl.attributes_for(:update_commodity)
          expect(assigns(:commodity)).to eq @commodity
        end

        it "changes @commodity's attributes" do
          patch :update, id: @commodity, commodity: FactoryGirl.attributes_for(:update_commodity)
          @commodity.reload
          expect(@commodity.name).to eq("update")
          #expect(@commodity.gtno).to eq("update")
          #expect(@commodity.email).to eq("update")
        end

        it "redirects to the commodity" do
          patch :update, id: @commodity, commodity: FactoryGirl.attributes_for(:commodity)
          expect(response).to redirect_to @commodity
        end
      end

      context "with invalid params" do
        it "does not change the commodity's attributes" do
          put :update, id: @commodity, commodity: FactoryGirl.attributes_for(:invalid_commodity)
          @commodity.reload
          expect(@commodity.name).to_not eq("invalid")
          expect(@commodity.name).to eq("test")
        end

        it "re-renders the 'edit' template" do
          put :update, id: @commodity, commodity: FactoryGirl.attributes_for(:invalid_commodity)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do

      it "destroys the requested commodity" do
        expect {
          delete :destroy, id: @commodity
        }.to change(Commodity, :count).by(-1)
      end

      it "redirects to the commodities list" do
        delete :destroy, id: @commodity
        expect(response).to redirect_to(commodities_url)
      end
    end
  end
  describe "test" do
    before :each do 
      FactoryGirl.create(:unit)
      #FactoryGirl.create(:goodstype)
      @commodity = FactoryGirl.create(:commodity)
      @user = FactoryGirl.create(:user)
      @superadmin = FactoryGirl.create(:superadmin)
      @unitadmin = FactoryGirl.create(:unitadmin)
      sign_in @unitadmin
      #puts @commodity.unit_id
    end

    it_behaves_like "commodity/test to commodities"
    
  end
end
