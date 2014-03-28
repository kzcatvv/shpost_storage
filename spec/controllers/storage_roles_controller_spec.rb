require 'spec_helper'

describe StorageRolesController do
    before :each do 
      @user2 = User.create(id: 3,name: "user1",email: "user1@111.com",username: "user1",unit_id: 1,password: "11111111",password_confirmation: "11111111",role: "user")
      @superadmin = FactoryGirl.create(:superadmin)
      
      @storage = FactoryGirl.create(:new_storage)
      @role = FactoryGirl.create(:role)
      sign_in @superadmin
      #@role = role.first
    
    end


    describe "GET storage_roles test" do
      #it "assigns all roles belongs to user 1" do
        #get :index
        #expect(assigns(:roles)).to eq([@role1, @role2])
      #end

      it " get the index route action" do
        { :get => "/storages/1/roles" }.should route_to("action"=>"index", "controller"=>"storage_roles", "storage_id"=>"1")
      end

      it " get the index roles" do
          get :index , storage_id: 1
          expect(assigns(:roles)).to eq(@role)
      end

      it " get the new route action" do
        { :get => "/storages/1/roles/new" }.should route_to("action"=>"new", "controller"=>"storage_roles", "storage_id"=>"1")
      end

      it " get the new role" do
          get :new, storage_id: 1
          expect(assigns(:role)).to be_a_new(Role)
      end

      it " get the create route action" do
        { :post => "/storages/1/roles" }.should route_to("action"=>"create", "controller"=>"storage_roles", "storage_id"=>"1")
      end

      it " get the create role" do
          expect { post :create, storage_id: 1, role: FactoryGirl.attributes_for(:new_role) }.to change(Role, :count).by(1)
      end

      # it " get the edit route action" do
      #   { :get => "/users/1/roles/1/edit" }.should route_to("action"=>"edit", "controller"=>"roles", "user_id"=>"1", "id"=>"1")
      # end

      # it "renders the edit view" do
      #   get :edit, user_id: 1,id: 1
      #   expect(response).to render_template :edit
      # end

      it " get the show route action" do
        { :get => "/storages/1/roles/1" }.should route_to("action"=>"show", "controller"=>"storage_roles", "storage_id"=>"1", "id"=>"1")
      end

      it " get the show role" do
          get :show, storage_id: 1, id: 1
        expect(assigns(:role)).to eq(@role)
      end

      # it " get the update route action" do
      #   { :patch => "/users/1/roles/1" }.should route_to("action"=>"update", "controller"=>"roles", "user_id"=>"1", "id"=>"1")
      # end

    end
end
