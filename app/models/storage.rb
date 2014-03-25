class Storage < ActiveRecord::Base
   belongs_to :unit

   validates :name, presence: true,
                    uniqueness: { case_sensitive: false }

end
