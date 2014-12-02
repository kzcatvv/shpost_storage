class PurchaseArrival < ActiveRecord::Base
  belongs_to :purchase_detail
  has_one :unit, through: :purchase_detail

  # STATUS = {waiting: 'waiting', checked: 'checked'}

  after_save :change_detail_status

  # def check
  #   if arrival_check
  #     self.update(status: STATUS[:checked])
  #   end
  # end

  # def arrival_check
  #   return true
  # end

  def waiting_amount
    self.arrived_amount - self.purchase_detail.purchase.stock_logs.where(business_id: self.purchase_detail.purchase.business_id, supplier_id: self.purchase_detail.supplier_id, specification_id: self.purchase_detail.specification_id, batch_no: self.batch_no).sum(:amount)
  end

  def change_detail_status
    if waiting_amount != 0
      self.purchase_detail.status = "waiting"
    end
  end
end
