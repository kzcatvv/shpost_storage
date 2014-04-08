require 'spec_helper'

describe UnitUsersController do

    before :each do 
      Unit.destroy_all
      User.destroy_all
      @unit1 = Unit.create(id: 1,name: "unit1",desc: "unit1")
      @unit2 = Unit.create(id: 2,name: "unit2",desc: "unit2")
      @user11 = User.create(id: 11,name: "user1",email: "user1@111.com",username: "user1",unit_id: 1,password: "11111111",password_confirmation: "11111111",role: "user")
      @user12 = User.create(id: 12,name: "user2",email: "user2@111.com",username: "user2",unit_id: 1,password: "11111111",password_confirmation: "11111111",role: "user")
      @user13 = User.create(id: 13,name: "user3",email: "user3@111.com",username: "user3",unit_id: 2,password: "11111111",password_confirmation: "11111111",role: "user")
      @superadmin = FactoryGirl.create(:superadmin)
      @user = FactoryGirl.create(:new_user)
      
      sign_in @superadmin
      #@user = User.first
    
    end

    describe "GET unit_users test" do
      #it "assigns all users belongs to unit 1" do
        #get :index
        #expect(assigns(:users)).to eq([@user1, @user2])
      #end

      it " get the index route action" do
        { :get => "/units/1/users" }.should route_to("action"=>"index", "controller"=>"unit_users", "unit_id"=>"1")
      end

      it " get the index users" do
          get :index , unit_id: 1
          expect(assigns(:users)).to eq([@user11,@user12,@user])
      end

      it " get the new route action" do
        { :get => "/units/1/users/new" }.should route_to("action"=>"new", "controller"=>"unit_users", "unit_id"=>"1")
      end

      it " get the new user" do
          get :new, unit_id: 1
          expect(assigns(:user)).to be_a_new(User)
      end

      it " get the create route action" do
        { :post => "/units/1/users" }.should route_to("action"=>"create", "controller"=>"unit_users", "unit_id"=>"1")
      end

      it " get the create user" do
          expect { post :create, unit_id: 1, user: FactoryGirl.attributes_for(:user) }.to change(User, :count).by(1)
      end

      it "assigns a newly created user_log as @user_log with creating user" do
          post :create, unit_id: 1, user: FactoryGirl.attributes_for(:user)

          expect(assigns(:user_log)).to be_a(UserLog)
          expect(assigns(:user_log)).to be_persisted
          expect(assigns(:user_log).object_class).to eq 'User'
          expect(assigns(:user_log).object_primary_key).to eq assigns(:user).id
          expect(assigns(:user_log).operation).to eq '新增用户管理'
      end

      it " get the edit route action" do
        { :get => "/units/1/users/1/edit" }.should route_to("action"=>"edit", "controller"=>"unit_users", "unit_id"=>"1", "id"=>"1")
      end

      it "renders the edit view" do
        get :edit, unit_id: 1,id: 11
        expect(response).to render_template :edit
      end

      it " get the show route action" do
        { :get => "/units/1/users/1" }.should route_to("action"=>"show", "controller"=>"unit_users", "unit_id"=>"1", "id"=>"1")
      end

      it " get the show user" do
          get :show, unit_id: 1, id: 11
        expect(assigns(:user)).to eq(@user11)
      end

      it " get the update route action" do
        { :patch => "/units/1/users/1" }.should route_to("action"=>"update", "controller"=>"unit_users", "unit_id"=>"1", "id"=>"1")
      end

      it "assigns a newly created user_log as @user_log with destroying user" do
        expect {
          delete :destroy, unit_id: 1, id: @user
        }.to change(UserLog, :count).by(1)
        expect(assigns(:user_log)).to be_a(UserLog)
        expect(assigns(:user_log)).to be_persisted
        expect(assigns(:user_log).object_class).to eq 'User'
        expect(assigns(:user_log).object_primary_key).to eq assigns(:user).id
        expect(assigns(:user_log).operation).to eq '删除用户管理'
      end

      #it "changes @user's attributes" do
          #patch :update, unit_id: 1, id: @user, user: FactoryGirl.attributes_for(:update_user)
          #@user.reload
          #expect(@user.username).to eq("update_username_test")
          #expect(@user.name).to eq("update_name")
          #expect(@user.email).to eq("update_user@example.com")
      #end

      
    end
end
