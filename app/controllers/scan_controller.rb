class ScanController < ApplicationController
  load_and_authorize_resource  :purchase, parent: false

  def scan
    # binding.pry
    @scans = Array.new
    if ! @purchase.blank?
      @purchase.purchase_details.each do |purchase_detail|
        @scans << purchase_detail
      end
    end
  end

  def check
    # binding.pry
    if ! @purchase.blank?
      @purchase.purchase_details.each do |purchase_detail|
        purchase_detail.amount = params["realam_#{purchase_detail.id}".to_sym]
        purchase_detail.save
      end
      respond_to do |format|
        format.html { redirect_to purchases_url}
      end
    end
  end
end
