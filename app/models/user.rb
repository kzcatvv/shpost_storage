class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :username, :name, :role, :message => '不能为空字符'#,

  validates_uniqueness_of :username, :message => '该用户已存在'

  ROLE = { superadmin: '超级用户', admin: '管理员' }

  def rolename
    User::ROLE[role.to_sym]
  end

  def superadmin?
    (role.eql? 'superadmin') ? true : false
  end

  def admin?
    (role.eql? 'admin') ? true : false
  end

  def email_required?
    false
  end

  def password_required?
    encrypted_password.blank? ? true : false
  end
end
