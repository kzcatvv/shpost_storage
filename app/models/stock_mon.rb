class StockMon < ActiveRecord::Base
	belongs_to :storage
	belongs_to :business
	belongs_to :supplier
	belongs_to :specification

  def stock_mon_cnt
  	@interface_status = '0' 
  	sum_dt = DateTime.parse((Time.now-1.months).to_s).strftime('%Y%m').to_s
    begin
  		stock_cnt_hash = Stock.includes(:storage).group(:business_id,:supplier_id,:specification_id,:storage_id).sum(:actual_amount)
  		stock_cnt_hash.each do |key,value|
  			# if Integer(value) > 0
  				StockMon.create(summ_date: sum_dt,storage_id: key[3],business_id: key[0],supplier_id: key[1],specification_id: key[2],amount: value)
  			# end
  		end
  	rescue Exception => e
      Rails.logger.error e.message
      @interface_status = '1'
      #Rails.errors e.message
    ensure
      ActiveRecord::Base.connection_pool.release_connection
      # puts "#{@title} : #{@count}"
    end
  end
end
