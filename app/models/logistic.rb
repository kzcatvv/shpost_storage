class Logistic < ActiveRecord::Base

  def is_default_name
     if is_default
        name = "是"
     else
        name = "否"
     end
  end

  def is_getnum_name
     if is_getnum
        name = "是"
     else
        name = "否"
     end
  end

	def getMailNum(sqzmc,ywdl,ywzl,sqsl)
		  case self.print_format
      when 'tcbd'
        if self.is_getnum
          begin
            url = URI.parse("#{GETNUM_URL}")
            Net::HTTP.start(url.host, url.port) do |http|
                req = Net::HTTP::Post.new(url.path)
                req.set_form_data({ 'callMethod' => 'getMailNum', 'sqzmc' => sqzmc, 'ywdl' => ywdl, 'ywzl' => ywzl, 'sqsl' => sqsl })
                rspback = http.request(req).body
				        return rspback   
            end
          rescue =>exception  
            return nil
          end
        end
      end
	end


end
