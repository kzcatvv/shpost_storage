require 'spec_helper'

describe KeyclientorderOrdersController do

    before :each do

      @superadmin = FactoryGirl.create(:superadmin)
      #@unit1 = Unit.create(id: 1,name: "unit1")
      @storage1 = Storage.create(id: 1,unit_id: 1,name: "storage1")
      @role1 = Role.create(user: @superadmin,storage_id: 1,role: "admin")
      @order = FactoryGirl.create(:order)
      @orderdetail = FactoryGirl.create(:order_detail)
      @goodstype1 = Goodstype.create(id: 1,gtno: 1,name: "goodstype1",unit_id: 1)
      @commodity1 = Commodity.create(id: 1,cno: 1,name: "commodity1",goodstype_id: 1,unit_id: 1)
      @specification1 = FactoryGirl.create(:specification)
      @keyclientorder1 = Keyclientorder.create(id: 1,keyclient_name: "keyclientorder1",keyclient_addr: "111",contact_person: "name1",unit_id: 1,phone: "11111111",storage_id: 1,batch_id: "2014041401")
      @keyclientorder2 = Keyclientorder.create(id: 2,keyclient_name: "keyclientorder2",keyclient_addr: "222",contact_person: "name2",unit_id: 1,phone: "11111111",storage_id: 1,batch_id: "2014041402")
      @keyclientorderdtl1 = Keyclientorderdetail.create(id: 1,keyclientorder_id: 2,specification_id: 1,amount: 2)

      
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
          expect(assigns(:order)).to be_a_new(Order)
      end

      it " get the create route action" do
        { :post => "/keyclientorders/1/orders" }.should route_to("action"=>"create", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1")
      end

      it " get the create order" do
          session[:current_storage] = @storage1.id
          expect { post :create, keyclientorder_id: 2, order: FactoryGirl.attributes_for(:new_order) }.to change(Order, :count).by(1)
          expect { post :create, keyclientorder_id: 2, order: FactoryGirl.attributes_for(:new_order) }.to change(OrderDetail, :count).by(1)
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

      it " get the destroy route action" do
        { :delete => "/keyclientorders/1/orders/1" }.should route_to("action"=>"destroy", "controller"=>"keyclientorder_orders", "keyclientorder_id"=>"1", "id"=>"1")
      end

      it " delete the order" do
          #expect { delete :destroy, keyclientorder_id: 1, id: 1 }.to change(Keyclientorder, :count).by(-1)
          expect { delete :destroy, keyclientorder_id: 1, id: 1 }.to change(Order, :count).by(-1)
          #expect { delete :destroy, keyclientorder_id: 1, id: 1 }.to change(OrderDetail, :count).by(-1)
      end

    end

end
