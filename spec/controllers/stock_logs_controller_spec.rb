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

describe StockLogsController do

  # This should return the minimal set of attributes required to create a valid
  # StockLog. As you add validations to StockLog, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # StockLogsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "admin access" do
    before :each do
      StockLog.destroy_all
      @stock_log1 = FactoryGirl.create(:stock_log)
      @stock_log2 = FactoryGirl.create(:stock_log, operation_type: StockLog::OPERATION_TYPE[:out])
      @stock_log3 = FactoryGirl.create(:stock_log, operation_type: StockLog::OPERATION_TYPE[:reset])
      @checked_stock_log = FactoryGirl.create(:checked_stock_log)

      @user = FactoryGirl.create(:superadmin)
      #@user = User.first
      
      sign_in @user
    end

    describe "GET index" do
      it "assigns all stock_logs as @stock_logs" do
        get :index
        expect(assigns(:stock_logs)).to eq([@stock_log1, @stock_log2, @stock_log3, @checked_stock_log])
      end

      it "renders the index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "assigns the requested stock_log as @stock_log" do
        get :show, id: @stock_log1
        expect(assigns(:stock_log)).to eq(@stock_log1)
      end

      it "renders the show view" do
        get :show, id: @stock_log1
        expect(response).to render_template :show
      end
    end

    describe "PATCH check" do
      context "with waiting stock_log" do
        it "assigns the requested @stock_log checked by waiting stock_log with operation_type in" do
          patch :check, id: @stock_log1
          amount1 = @stock_log1.stock.actual_amount
          expect(assigns(:stock_log)).to be_checked
          expect(assigns(:stock_log).checked_at).not_to be_blank
          expect(assigns(:stock_log).stock.actual_amount).to eq(amount1 + @stock_log1.amount)
        end

        it "assigns the requested @stock_log checked by waiting stock_log with operation_type out" do
          patch :check, id: @stock_log2
          amount1 = @stock_log2.stock.actual_amount
          expect(assigns(:stock_log)).to be_checked
          expect(assigns(:stock_log).checked_at).not_to be_blank
          expect(assigns(:stock_log).stock.actual_amount).to eq(amount1 - @stock_log1.amount)
        end

        it "assigns the requested @stock_log checked by waiting stock_log with operation_type reset" do
          patch :check, id: @stock_log3
          expect(assigns(:stock_log)).to be_checked
          expect(assigns(:stock_log).checked_at).not_to be_blank
          expect(assigns(:stock_log).stock.actual_amount).to eq(@stock_log3.amount)
        end

        it "assigns the requested @stock_log not change by checked stock_log with operation_type reset" do
          patch :check, id: @checked_stock_log
          amount1 = @checked_stock_log.stock.actual_amount
          expect(assigns(:stock_log)).to be_checked
          expect(assigns(:stock_log).checked_at).not_to be_blank
          expect(assigns(:stock_log).stock.actual_amount).to eq(amount1)
        end
      end
    end
  end
end
