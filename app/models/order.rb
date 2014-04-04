class Order < ActiveRecord::Base
		validates_presence_of :no, :message => '不能为空'
end
