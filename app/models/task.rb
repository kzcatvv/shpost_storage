class Task < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :user
  belongs_to :storage
  has_one :unit, through: :storage

  validates_uniqueness_of :barcode, :code

  STATUS = {doing: 'doing', done: 'done'}

  ASSIGN_TYPE = {assigned: 'assigned', joined: 'joined'}

  OPERATE_TYPE = {Purchase: 'in', MoveStock: 'move', ManualStock: 'out', Keyclientorder: 'out', OrderReturn: 'in'}

  def done?
    (status.eql? Task::STATUS[:done]) ? true : false
  end

  def self.save_task(parent,storage_id,user_id=nil)
    task = Task.where(parent: parent, status: STATUS[:doing], assign_type: ASSIGN_TYPE[:assigned]).first
    if task.blank?
      Task.create(parent: parent, code: generate_code(), user_id: user_id, status: STATUS[:doing], storage_id: storage_id, assign_type: ASSIGN_TYPE[:assigned])
    else
      if !user_id.blank?
        task.update(user_id: user_id)
      end
    end
  end

  def self.tasker_in_work(parent)
    task = Task.where(parent: parent, status: STATUS[:doing], assign_type: ASSIGN_TYPE[:assigned]).first
    if task.blank?
      return nil
    else
      return task.user
    end
  end

  private
  def self.generate_code()
    exist_flg = true
    begin
      code = rand_code()
      exist_flg = (Task.where(code: code, status: STATUS[:doing]).size > 0)
    end while (exist_flg)

    return code
  end

  def self.rand_code()
    # 123 -> "0123"
    return "%04d" % rand(9999)
  end
end
