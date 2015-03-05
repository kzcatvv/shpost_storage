class Task < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  belongs_to :user
  belongs_to :storage
  has_one :unit, through: :storage

  # validates_uniqueness_of :barcode, :code

  STATUS = {doing: 'doing', done: 'done'}

  ASSIGN_TYPE = {assigned: 'assigned', joined: 'joined'}
  TASK_TYPE = {in: 'in', out: 'out', reset: 'reset', move: 'move'}

  OPERATE_TYPE = {Purchase: 'in', MoveStock: 'move', ManualStock: 'out', Keyclientorder: 'out', OrderReturn: 'in', Inventory: 'reset'}

  OPERATE_TYPE_SHOW = {Purchase: '采购入库', MoveStock: '移库', ManualStock: '批量出库', Keyclientorder: '订单出库', OrderReturn: '退货入库', Inventory: '盘点'}

  STATUS_SHOW = {doing: '未完成', done: '完成'}

  before_create :set_code

  def done?
    (status.eql? Task::STATUS[:done]) ? true : false
  end

  def self.save_task(parent, storage_id, user_id = nil)
    task = Task.where(parent: parent, status: STATUS[:doing], assign_type: ASSIGN_TYPE[:assigned]).first
    if task.blank?
      type = OPERATE_TYPE[parent.class.name.to_sym]

      title = ""
      if parent.respond_to? :batch_no
        if title.blank? && !parent.batch_no.blank?
          title = "#{parent.batch_no}_#{OPERATE_TYPE_SHOW[parent.class.name.to_sym]}"
        end
      end
      if parent.respond_to? :no
        if title.blank? && !parent.no.blank?
          title = "#{parent.no}_#{OPERATE_TYPE_SHOW[parent.class.name.to_sym]}"
        end
      end
      if title.blank?
        title = parent.class.name
      end
      Task.create!(parent: parent, user_id: user_id, status: STATUS[:doing], storage_id: storage_id, assign_type: ASSIGN_TYPE[:assigned], task_type: type, title: title)
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

  def set_code()
    if self.code.blank?
      self.code = Task.generate_code()
    end
  end
end
