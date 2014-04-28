namespace :transmitter do
  namespace :bankcomm do
    desc "BankComm Transmitter"
      task :order_update => :environment do
        generate_params 'transmitter.bankcomm.order_update'

        while 1==1 do
          @count += 1
          begin
            # body = your_class.your_def
            # body.format is a hash like {'plaintext' => '{[{prodId : '000001'}, {prodId : '000002'}]}', 'sign' => 's235$s1@kd9%ds6136', 'toalno' => '2'}
            # transmit_with_http(@uri, body)
          rescue Exception => e
            # puts e.message
            Rails.errors e.message
          ensure
            ActiveRecord::Base.connection_pool.release_connection
            puts "#{@title} : #{@count}"
          end
        sleep @interval
      end
    end
  end

  private
  def self.transmit_with_http(uri, body)
    @clnt ||= HTTPClient.new

    log_info ("post " + @title), body

    res = @clnt.post(uri, body)

    log_info ("return " + @title), body

    res.body
  end

  def self.generate_params(title)
    @title = title
    @interval = I18n.t "#{@title}.interval"
    @interval ||= 1800
    @uri = I18n.t "#{@title}.uri"
    @count = 0
  end

  def self.log_info(title, body)
    Rails.logger.info "********** #{Time.now.to_s} #{title}**********"
    Rails.logger.info body
    Rails.logger.info "****************************************************************************"
  end
end
