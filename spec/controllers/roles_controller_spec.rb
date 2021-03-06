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

describe RolesController do

  # This should return the minimal set of attributes required to create a valid
  # Role. As you add validations to Role, be sure to
  # adjust the attributes here as well.
  #let(:valid_attributes) { { "role_id" => "1" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RolesController. Be sure to keep this updated too.
  #let(:valid_session) { {} }
  before :each do 
      @user1 = User.create(id: 1,name: "user1",email: "user1@111.com",username: "user1",unit_id: 1,password: "11111111",password_confirmation: "11111111",role: "user")
      @superadmin = FactoryGirl.create(:superadmin)
      @role = FactoryGirl.create(:role)
      sign_in @superadmin
      #@role = role.first
    
    end

  # describe "GET index" do
  #   it "assigns all roles as @roles" do
  #     role = Role.create! valid_attributes
  #     get :index, {}, valid_session
  #     assigns(:roles).should eq([role])
  #   end
  # end

  # describe "GET show" do
  #   it "assigns the requested role as @role" do
  #     role = Role.create! valid_attributes
  #     get :show, {:id => role.to_param}, valid_session
  #     assigns(:role).should eq(role)
  #   end
  # end

  # describe "GET new" do
  #   it "assigns a new role as @role" do
  #     get :new, {}, valid_session
  #     assigns(:role).should be_a_new(Role)
  #   end
  # end

  #describe "GET edit" do
    #it "assigns the requested role as @role" do
      #role = Role.create! valid_attributes
      #get :edit, {:id => role.to_param}, valid_session
      #assigns(:role).should eq(role)
    #end
  #end

  # describe "POST create" do
  #   describe "with valid params" do
  #     it "creates a new Role" do
  #       expect {
  #         post :create, {:role => valid_attributes}, valid_session
  #       }.to change(Role, :count).by(1)
  #     end

  #     it "assigns a newly created role as @role" do
  #       post :create, {:role => valid_attributes}, valid_session
  #       assigns(:role).should be_a(Role)
  #       assigns(:role).should be_persisted
  #     end

  #     it "redirects to the created role" do
  #       post :create, {:role => valid_attributes}, valid_session
  #       response.should redirect_to(Role.last)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns a newly created but unsaved role as @role" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Role.any_instance.stub(:save).and_return(false)
  #       post :create, {:role => { "role_id" => "invalid value" }}, valid_session
  #       assigns(:role).should be_a_new(Role)
  #     end

  #     it "re-renders the 'new' template" do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Role.any_instance.stub(:save).and_return(false)
  #       post :create, {:role => { "role_id" => "invalid value" }}, valid_session
  #       response.should render_template("new")
  #     end
  #   end
  # end

  #describe "PUT update" do
    #describe "with valid params" do
      #it "updates the requested role" do
        #role = Role.create! valid_attributes
        # Assuming there are no other roles in the database, this
        # specifies that the Role created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        #Role.any_instance.should_receive(:update).with({ "role_id" => "1" })
        #put :update, {:id => role.to_param, :role => { "role_id" => "1" }}, valid_session
      #end

      #it "assigns the requested role as @role" do
        #role = Role.create! valid_attributes
        #put :update, {:id => role.to_param, :role => valid_attributes}, valid_session
        #assigns(:role).should eq(role)
      #end

      #it "redirects to the role" do
        #role = Role.create! valid_attributes
        #put :update, {:id => role.to_param, :role => valid_attributes}, valid_session
        #response.should redirect_to(role)
      #end
    #end

    #describe "with invalid params" do
      #it "assigns the role as @role" do
        #role = Role.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        #Role.any_instance.stub(:save).and_return(false)
        #put :update, {:id => role.to_param, :role => { "role_id" => "invalid value" }}, valid_session
        #assigns(:role).should eq(role)
      #end

      #it "re-renders the 'edit' template" do
        #role = Role.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        #Role.any_instance.stub(:save).and_return(false)
        #put :update, {:id => role.to_param, :role => { "role_id" => "invalid value" }}, valid_session
        #response.should render_template("edit")
      #end
    #end
  #end

  # describe "DELETE destroy" do
  #   it "destroys the requested role" do
  #     role = Role.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => role.to_param}, valid_session
  #     }.to change(Role, :count).by(-1)
  #   end

  #   it "redirects to the roles list" do
  #     role = Role.create! valid_attributes
  #     delete :destroy, {:id => role.to_param}, valid_session
  #     response.should redirect_to(roles_url)
  #   end
  # end
  describe "GET user_roles test" do
      #it "assigns all roles belongs to user 1" do
        #get :index
        #expect(assigns(:roles)).to eq([@role1, @role2])
      #end

      it " get the index route action" do
        { :get => "/users/1/roles" }.should route_to("action"=>"index", "controller"=>"roles", "user_id"=>"1")
      end

      it " get the index roles" do
          get :index , user_id: 1
          expect(assigns(:roles)).to eq(@role)
      end

      it " get the new route action" do
        { :get => "/users/1/roles/new" }.should route_to("action"=>"new", "controller"=>"roles", "user_id"=>"1")
      end

      it " get the new role" do
          get :new, user_id: 2
          expect(assigns(:role)).to be_a_new(Role)
      end

      it " get the create route action" do
        { :post => "/users/1/roles" }.should route_to("action"=>"create", "controller"=>"roles", "user_id"=>"1")
      end

      it " get the create role" do
          expect { post :create, user_id: 2, role: FactoryGirl.attributes_for(:new_role) }.to change(Role, :count).by(1)
      end

      # it " get the edit route action" do
      #   { :get => "/users/1/roles/1/edit" }.should route_to("action"=>"edit", "controller"=>"roles", "user_id"=>"1", "id"=>"1")
      # end

      # it "renders the edit view" do
      #   get :edit, user_id: 1,id: 1
      #   expect(response).to render_template :edit
      # end

      it " get the show route action" do
        { :get => "/users/2/roles/1" }.should route_to("action"=>"show", "controller"=>"roles", "user_id"=>"2", "id"=>"1")
      end

      it " get the show role" do
          get :show, user_id: 1, id: 1
        expect(assigns(:role)).to eq(@role)
      end

      # it " get the update route action" do
      #   { :patch => "/users/1/roles/1" }.should route_to("action"=>"update", "controller"=>"roles", "user_id"=>"1", "id"=>"1")
      # end

    end

end
