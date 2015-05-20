class MoveStock < ActiveRecord::Base
	  belongs_to :unit
  	belongs_to :storage
  	has_many :stock_logs, as: :parent
    has_many :tasks, as: :parent

  	STATUS = { opened: 'opened', moving: 'moving',moved: 'moved',closed: 'closed'}

  	def status_name
    	status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  	end

  	def check!
    	self.stock_logs.each do |x|
      		x.check!
    	end

    	if self.all_checked?
    		self.update(status: 'moved')
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
