class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :storage

  validates_presence_of :user_id, :storage_id, :role, :message => '不能为空字符'
  
  ROLE = { purchase: '采购员', sorter: '拣货员' }

  def purchase?
    (role.eql? 'purchase') ? true : false
  end

  def sorter?
    (role.eql? 'sorter') ? true : false
  end
end
