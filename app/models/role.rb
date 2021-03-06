class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :storage

  validates_presence_of :user_id, :storage_id, :role, :message => '不能为空字符'
  validates_uniqueness_of :user_id, scope: [:storage_id, :role], :message => '该角色在该仓库中角色已存在'
  
  ROLE = { admin: '管理员', purchase: '采购员', sorter: '库存管理员', order: '订单管理员'}

  def purchase?
    (role.eql? 'purchase') ? true : false
  end

  def sorter?
    (role.eql? 'sorter') ? true : false
  end

  def order?
    (role.eql? 'order') ? true : false
  end

  def self.get_storages_by_user_id(user_id)
    Role.where("user_id = ?", user_id).group(:storage_id)
  end
end
