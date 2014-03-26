class Storage < ActiveRecord::Base
   belongs_to :unit

   validates_presence_of :name, :unit_id, :message => '不能为空字符'

end
