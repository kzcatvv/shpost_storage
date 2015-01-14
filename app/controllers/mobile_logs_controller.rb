class MobileLogsController < ApplicationController
  before_action :set_mobile_log, only: [:show, :edit, :update, :destroy]

  def index
    @mobile_logs = MobileLog.all
    respond_with(@mobile_logs)
  end

  def show
    respond_with(@mobile_log)
  end

  def new
    @mobile_log = MobileLog.new
    respond_with(@mobile_log)
  end

  def edit
  end

  def create
    @mobile_log = MobileLog.new(mobile_log_params)
    @mobile_log.save
    respond_with(@mobile_log)
  end

  def update
    @mobile_log.update(mobile_log_params)
    respond_with(@mobile_log)
  end

  def destroy
    @mobile_log.destroy
    respond_with(@mobile_log)
  end

  private
    def set_mobile_log
      @mobile_log = MobileLog.find(params[:id])
    end

    def mobile_log_params
      params[:mobile_log]
    end
end
