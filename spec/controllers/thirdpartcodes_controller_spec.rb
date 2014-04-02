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

describe ThirdpartcodesController do

  # This should return the minimal set of attributes required to create a valid
  # Thirdpartcode. As you add validations to Thirdpartcode, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "business_id" => "1" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ThirdpartcodesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all thirdpartcodes as @thirdpartcodes" do
      thirdpartcode = Thirdpartcode.create! valid_attributes
      get :index, {}, valid_session
      assigns(:thirdpartcodes).should eq([thirdpartcode])
    end
  end

  describe "GET show" do
    it "assigns the requested thirdpartcode as @thirdpartcode" do
      thirdpartcode = Thirdpartcode.create! valid_attributes
      get :show, {:id => thirdpartcode.to_param}, valid_session
      assigns(:thirdpartcode).should eq(thirdpartcode)
    end
  end

  describe "GET new" do
    it "assigns a new thirdpartcode as @thirdpartcode" do
      get :new, {}, valid_session
      assigns(:thirdpartcode).should be_a_new(Thirdpartcode)
    end
  end

  describe "GET edit" do
    it "assigns the requested thirdpartcode as @thirdpartcode" do
      thirdpartcode = Thirdpartcode.create! valid_attributes
      get :edit, {:id => thirdpartcode.to_param}, valid_session
      assigns(:thirdpartcode).should eq(thirdpartcode)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Thirdpartcode" do
        expect {
          post :create, {:thirdpartcode => valid_attributes}, valid_session
        }.to change(Thirdpartcode, :count).by(1)
      end

      it "assigns a newly created thirdpartcode as @thirdpartcode" do
        post :create, {:thirdpartcode => valid_attributes}, valid_session
        assigns(:thirdpartcode).should be_a(Thirdpartcode)
        assigns(:thirdpartcode).should be_persisted
      end

      it "redirects to the created thirdpartcode" do
        post :create, {:thirdpartcode => valid_attributes}, valid_session
        response.should redirect_to(Thirdpartcode.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved thirdpartcode as @thirdpartcode" do
        # Trigger the behavior that occurs when invalid params are submitted
        Thirdpartcode.any_instance.stub(:save).and_return(false)
        post :create, {:thirdpartcode => { "business_id" => "invalid value" }}, valid_session
        assigns(:thirdpartcode).should be_a_new(Thirdpartcode)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Thirdpartcode.any_instance.stub(:save).and_return(false)
        post :create, {:thirdpartcode => { "business_id" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested thirdpartcode" do
        thirdpartcode = Thirdpartcode.create! valid_attributes
        # Assuming there are no other thirdpartcodes in the database, this
        # specifies that the Thirdpartcode created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Thirdpartcode.any_instance.should_receive(:update).with({ "business_id" => "1" })
        put :update, {:id => thirdpartcode.to_param, :thirdpartcode => { "business_id" => "1" }}, valid_session
      end

      it "assigns the requested thirdpartcode as @thirdpartcode" do
        thirdpartcode = Thirdpartcode.create! valid_attributes
        put :update, {:id => thirdpartcode.to_param, :thirdpartcode => valid_attributes}, valid_session
        assigns(:thirdpartcode).should eq(thirdpartcode)
      end

      it "redirects to the thirdpartcode" do
        thirdpartcode = Thirdpartcode.create! valid_attributes
        put :update, {:id => thirdpartcode.to_param, :thirdpartcode => valid_attributes}, valid_session
        response.should redirect_to(thirdpartcode)
      end
    end

    describe "with invalid params" do
      it "assigns the thirdpartcode as @thirdpartcode" do
        thirdpartcode = Thirdpartcode.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Thirdpartcode.any_instance.stub(:save).and_return(false)
        put :update, {:id => thirdpartcode.to_param, :thirdpartcode => { "business_id" => "invalid value" }}, valid_session
        assigns(:thirdpartcode).should eq(thirdpartcode)
      end

      it "re-renders the 'edit' template" do
        thirdpartcode = Thirdpartcode.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Thirdpartcode.any_instance.stub(:save).and_return(false)
        put :update, {:id => thirdpartcode.to_param, :thirdpartcode => { "business_id" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested thirdpartcode" do
      thirdpartcode = Thirdpartcode.create! valid_attributes
      expect {
        delete :destroy, {:id => thirdpartcode.to_param}, valid_session
      }.to change(Thirdpartcode, :count).by(-1)
    end

    it "redirects to the thirdpartcodes list" do
      thirdpartcode = Thirdpartcode.create! valid_attributes
      delete :destroy, {:id => thirdpartcode.to_param}, valid_session
      response.should redirect_to(thirdpartcodes_url)
    end
  end

end
