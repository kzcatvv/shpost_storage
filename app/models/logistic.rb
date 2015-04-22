class Logistic < ActiveRecord::Base
	belongs_to :storage

	def getMailNum(sqzmc,ywdl,ywzl,sqsl)
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
