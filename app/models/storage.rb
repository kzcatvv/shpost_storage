class Storage < ActiveRecord::Base
   belongs_to :unit
   has_many :roles

   validates_presence_of :name, :unit_id, :message => '不能为空字符'
   validates_uniqueness_of :name, :message => '该仓库已存在'

   def self.get_default_storage(unit_id)
   	# todo: add a column to show which storage is default in the unit.
   	Storage.where("unit_id = ?",unit_id).first
   end

end
