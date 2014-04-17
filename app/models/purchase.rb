class Purchase < ActiveRecord::Base
	belongs_to :unit
	belongs_to :business
  belongs_to :storage
	has_many :purchase_details, dependent: :destroy
  has_many :stock_logs, through: :purchase_details
	has_many :stocks, through: :stock_logs  

	validates_presence_of :no, :name, message: '不能为空'
  validates_numericality_of :sum, allow_blank: true
  validates_numericality_of :amount, only_integer: true, allow_blank: true # 必須是整數

  STATUS = { opened: 'opened', closed: 'closed'}

  def status_name
    status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  end

  def close
    if self.can_close?
      self.update(status: STATUS[:closed])
    else
      false
    end
  end

  def check
    self.stock_logs.each do |x|
      x.check
    end
  end

  def can_close?
    all_checked? #&& closed?
  end

  def all_checked?
    self.purchase_details.each do |x|
      if ! x.all_checked?
        return false
      end
    end
  end

  def closed?
    self.status.eql? STATUS[:closed]
  end

end

