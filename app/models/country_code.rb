class CountryCode < ActiveRecord::Base
  def is_mail_name
     if is_mail
        name = "是"
     else
        name = "否"
     end
  end

  def get_code(chinese_name,english_name)
    if !chinese_name.blank?
      country_code = CountryCode.find_by(chinese_name:chinese_name)
    end
    if !english_name.blank?
      country_code = CountryCode.find_by(english_name:english_name)
    end
    return country_code.blank?? "":country_code.code
  end
end
