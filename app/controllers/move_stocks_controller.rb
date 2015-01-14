class MoveStocksController < ApplicationController
  load_and_authorize_resource

  def index
    @move_stocks_grid = initialize_grid(@move_stocks)

  end

  def show

  end

  def new
    
  end

  def edit
  end

  def create
    @move_stock.unit = current_user.unit
    @move_stock.status = MoveStock::STATUS[:opened]
    @move_stock.storage = current_storage

    respond_to do |format|
      if @move_stock.save
        format.html { redirect_to @move_stock, notice: I18n.t('controller.create_success_notice', model: '移库单') }
        format.json { render action: 'show', status: :created, location: @move_stock }
      else
        format.html { render action: 'new' }
        format.json { render json: @move_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @move_stock.update(move_stock_params)
        format.html { redirect_to @move_stock, notice: I18n.t('controller.update_success_notice', model: '移库单')  }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @move_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @move_stock.destroy
    respond_to do |format|
      format.html { redirect_to move_stocks_url }
      format.json { head :no_content }
    end
  end

  def movedetail
    @movestock = @move_stock
    @movestockid = @move_stock.id

    qrcode = RQRCode::QRCode.new('http://www.baidu.com/', :size => 4, :level => :h )
    @qr=qrcode.to_img
    direct = "#{Rails.root}/app/assets/images/"
    fnm = direct + "really_cool_qr_image.png"
    @qr=@qr.resize(200, 200).save(fnm)
  end

  def check
    @move_stock = MoveStock.find(params[:format])
    @stock_logs = @move_stock.stock_logs
    @stock_logs_grid = initialize_grid(@stock_logs)

      if @move_stock.check!
        redirect_to move_stocks_url 

      else
        redirect_to move_stocks_url
      end

  end

  private
    def set_move_stock
      @move_stock = MoveStock.find(params[:id])
    end

    def move_stock_params
      params.require(:move_stock).permit(:no, :unit_id, :amount, :sum, :desc, :status, :name, :storage_id, :barcode)
    end
end
