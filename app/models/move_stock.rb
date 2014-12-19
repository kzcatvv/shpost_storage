class MoveStock < ActiveRecord::Base
	belongs_to :unit
  	belongs_to :storage
  	has_many :stock_logs, as: :parent

  	STATUS = { opened: 'opened', closed: 'closed'}

  	def status_name
    	status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
  	end
end
