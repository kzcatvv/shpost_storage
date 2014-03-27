require 'spec_helper'

describe UnitUsersController do

    before :each do 
      @unit1 = Unit.create(id: 1,name: "unit1",desc: "unit1")
      @unit2 = Unit.create(id: 2,name: "unit2",desc: "unit2")
      @user1 = User.create(id: 1,name: "user1",email: "user1@111.com",username: "user1",unit_id: 1)
      @user2 = User.create(id: 2,name: "user2",email: "user2@111.com",username: "user2",unit_id: 1)
      @user3 = User.create(id: 3,name: "user3",email: "user3@111.com",username: "user3",unit_id: 2)


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
          expect(assigns(:users_grid)).to eq([@user1,@user2])
      end

      it " get the create route action" do
        { :post => "/units/1/users" }.should route_to("action"=>"create", "controller"=>"unit_users", "unit_id"=>"1")
      end

      it " get the new route action" do
        { :get => "/units/1/users/new" }.should route_to("action"=>"new", "controller"=>"unit_users", "unit_id"=>"1")
      end

      it " get the edit route action" do
        { :get => "/units/1/users/1/edit" }.should route_to("action"=>"edit", "controller"=>"unit_users", "unit_id"=>"1", "id"=>"1")
      end

      it " get the show route action" do
        { :get => "/units/1/users/1" }.should route_to("action"=>"show", "controller"=>"unit_users", "unit_id"=>"1", "id"=>"1")
      end

      it " get the show user" do
          get :index , unit_id: 1, id: 1
          expect(assigns(:user)).to eq(@user1)
      end

      it " get the update route action" do
        { :patch => "/units/1/users/1" }.should route_to("action"=>"update", "controller"=>"unit_users", "unit_id"=>"1", "id"=>"1")
      end
    end
end
