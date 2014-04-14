require 'spec_helper'

describe KeyclientorderOrdersController do

    before :each do 
      @user1 = User.create(id: 1,name: "user1",email: "user1@111.com",username: "user1",unit_id: 1,password: "11111111",password_confirmation: "11111111",role: "user")
      @superadmin = FactoryGirl.create(:superadmin)
      @order = FactoryGirl.create(:order)
      sign_in @superadmin
      #@role = role.first
    
    end

	describe "GET keyclientorder_order test" do
      #it "assigns all orders belongs to keyclientorder 1" do
        #get :index
        #expect(assigns(:orders)).to eq([@order1, @order2])
      #end

      it " get the index route action" do
        { :get => "/keyclientorders/1/orders" }.should route_to("action"=>"index", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1")
      end

      it " get the index orders" do
          get :index , keyclientorder_id: 1
          expect(assigns(:orders)).to eq(@order)
      end

      it " get the new route action" do
        { :get => "/keyclientorders/1/orders/new" }.should route_to("action"=>"new", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1")
      end

      it " get the new order" do
          get :new, keyclientorder_id: 2
          expect(assigns(:order)).to be_a_new(order)
      end

      it " get the create route action" do
        { :post => "/keyclientorders/1/orders" }.should route_to("action"=>"create", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1")
      end

      it " get the create order" do
          expect { post :create, keyclientorder_id: 2, order: FactoryGirl.attributes_for(:new_order) }.to change(order, :count).by(1)
      end

      it " get the edit route action" do
        { :get => "/keyclientorders/1/orders/1/edit" }.should route_to("action"=>"edit", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1", "id"=>"1")
      end

      it "renders the edit view" do
        get :edit, keyclientorder_id: 1,id: 1
        expect(response).to render_template :edit
      end

      it " get the show route action" do
        { :get => "/keyclientorders/2/orders/1" }.should route_to("action"=>"show", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"2", "id"=>"1")
      end

      it " get the show order" do
          get :show, keyclientorder_id: 1, id: 1
        expect(assigns(:order)).to eq(@order)
      end

      it " get the update route action" do
        { :patch => "/keyclientorders/1/orders/1" }.should route_to("action"=>"update", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1", "id"=>"1")
      end

    end

end
