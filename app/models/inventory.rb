class Inventory < ActiveRecord::Base
	belongs_to :unit
  	belongs_to :storage
  	has_many :stock_logs, as: :parent
    has_many :tasks, as: :parent

    INV_TYPE = {byarea: '按区域'}
    GOODS_INV_TYPE = {bybusiness: '按商户', byrel: '按商品关系'}
    STATUS = { opened: 'opened',inventoring: 'inventoring',closed: 'closed'}

    def inv_type_name
      inv_type.blank? ? "" : Inventory::INV_TYPE["#{inv_type}".to_sym]
    end

    def goods_type_name
      goods_inv_type.blank? ? "" : Inventory::GOODS_INV_TYPE["#{goods_inv_type}".to_sym]
    end

  	def status_name
    	status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  	end

    def check!
    	self.stock_logs.each do |x|
      		x.check!
    	end

    	if self.all_checked?
    		self.update(status: 'closed')
    	end
    end

    def all_checked?
    	self.stock_logs.each do |x|
      		if !x.checked?
      			return false
      		end
    	end
    	return true
    end

    def has_checked?
      self.stock_logs.each do |x|
        if x.checked?
          return true
        end
      end
      return false
    end

    def has_waiting_stock_logs()
      x = self.stock_logs.where(status: "waiting").size
      if x == 0
        return false
      else
        return true
      end
    end
end
