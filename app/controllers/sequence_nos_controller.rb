class SequenceNosController < ApplicationController
  load_and_authorize_resource :sequence_no

  def index
    @sequence_nos_grid = initialize_grid(@sequence_nos)
  end

  def show
    # respond_with(@sequence_no)
  end

  def new
    # @sequence_no = SequenceNo.new
    # respond_with(@sequence_no)
  end

  def edit
  end

  def create
    respond_to do |format|
      if @sequence_no.save
        format.html { redirect_to @sequence_no, notice: I18n.t('controller.create_success_notice', model: '号段')}
        format.json { render action: 'show', status: :created, location: @sequence_no }
      else
        format.html { render action: 'new' }
        format.json { render json: @sequence_no.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @sequence_no.update(sequence_no_params)
        format.html { redirect_to @sequence_no, notice: I18n.t('controller.update_success_notice', model: '号段') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sequence_no.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sequence_no.destroy
    respond_to do |format|
      format.html { redirect_to sequence_nos_url }
      format.json { head :no_content }
    end
  end

  
  private
    def set_sequence_no
      @sequence_no = SequenceNo.find(params[:id])
    end

    def sequence_no_params
      params.require(:sequence_no).permit(:unit_id, :storage_id, :logistic_id, :start_no, :end_no, :storage_no)
    end
end
