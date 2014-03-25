class Storage < ActiveRecord::Base
   belongs_to :unit
   has_many :roles

   validates_presence_of :name, :unit_id, :message => '不能为空字符'

end
