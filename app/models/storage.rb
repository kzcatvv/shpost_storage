class Storage < ActiveRecord::Base
   belongs_to :unit
   has_many :roles
   has_many :areas, dependent: :destroy

   validates_presence_of :name, :unit_id, :message => '不能为空字符'
   validates_uniqueness_of :name, :message => '该仓库已存在'

   after_update :change_area_shelf_type

   def default_type_name
     if default_storage
        name = "是"
     else
        name = "否"
     end
   end

   def need_pick_name
     if need_pick
        name = "是"
     else
        name = "否"
     end
   end

   def self.get_default_storage(unit_id)
   	# todo: add a column to show which storage is default in the unit.
   	# Storage.where("unit_id = ?",unit_id).first
    Storage.find_by(unit_id: unit_id, default_storage: true)
   end

  def get_sorter()
    sorters = []
    self.roles.each do |x|
      if x.sorter?
        sorters << x.user
      end
    end
    return sorters
  end

  def change_area_shelf_type
    if !self.need_pick
      self.areas.each do |a|
        if a.area_type.eql?"pick"
          a.area_type = "normal"
          a.save
          a.shelves.each do |s|
            if s.shelf_type.eql?"pick"
              s.shelf_type="normal"
              s.save
            end
          end
        end
      end
    end
  end
      

end
