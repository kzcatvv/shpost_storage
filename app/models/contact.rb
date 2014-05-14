class Contact < ActiveRecord::Base
  belongs_to :supplier
  has_and_belongs_to_many :relationships
end
