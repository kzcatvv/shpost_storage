class Specification < ActiveRecord::Base
   belongs_to :commodity

   validates_presence_of :commodity_id, :model, :message => '不能为空字符'
end
