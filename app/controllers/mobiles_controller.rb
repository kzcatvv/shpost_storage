class MobilesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource

  def index
    @mobiles_grid = initialize_grid(@mobiles, include: :user)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @mobile.save
    respond_with(@mobile)
  end

  def update
    @mobile.update(mobile_params)
    respond_with(@mobile)
  end

  def destroy
    @mobile.destroy
    respond_with(@mobile)
  end

  private
    def mobile_params
      params.require(:mobile).permit(:no, :cancel, :mobile_type)
    end
end
