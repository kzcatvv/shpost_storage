class CountryCode < ActiveRecord::Base
  def is_mail_name
     if is_mail
        name = "是"
     else
        name = "否"
     end
  end

  
end
