class OrderDetail < ActiveRecord::Base
  belongs_to :supplier
	belongs_to :specification
	belongs_to :order
  has_one :unit, through: :order
  has_one :order_return_detail
	has_and_belongs_to_many :stock_logs

  after_save :change_order_total_amount
  after_save :change_order_total_weight

  DEFECTIVE = { 0=> '非残次品', 1=> '残次品'}

  def defective_name
    defective.blank? ? "" : self.class.human_attribute_name("defective_#{defective}")
  end

	# validates_presence_of :name, :message => '不能为空'
  def relationship
    Relationship.find_relationship(specification, order.business, unit, supplier)
  end

  def all_checked?
    self.amount.eql? self.checked_amount
  end

  def checked_amount
    self.stock_logs.order_without_return.to_a.sum{|x| x.checked? ? x.amount : 0}
  end

  def change_order_total_amount
    self.order.total_amount = OrderDetail.where(order_id: self.order.id).sum(:amount)
    self.order.save
  end

  def change_order_total_weight
    order_details = OrderDetail.where(order_id: self.order.id)
    total_weight = 0
    order_details.each do |d|
      if !d.specification.blank?
        if (!d.specification.weight.blank?) && (!d.amount.blank?)
          total_weight += d.specification.weight * d.amount
        end 
      end
    end
    
    self.order.total_weight = total_weight
    self.order.save
  end

end
