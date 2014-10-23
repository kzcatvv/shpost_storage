class ScansController < ApplicationController
  # load_and_authorize_resource :purchase, parent: false
  # load_and_authorize_resource :manual_stock, parent: false

  # before_action :scan_filter

  def scans
    binding.pry
    # binding.pry
    # @scans = Array.new
    # if ! @purchase.blank?
    #   @purchase.purchase_details.each do |purchase_detail|
    #     @scans << purchase_detail
    #   end
    # end
  end

  def check
    if ! @scans.blank?
      @scans.each do |scan|
        scan.amount = params["realam_#{scan.id}".to_sym]
        scan.save
      end
      respond_to do |format|
        format.html { redirect_to @request_url}
      end
    end
  end

end
