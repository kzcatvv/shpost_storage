class InterfaceInfo < ActiveRecord::Base

  STATUS = { success: '成功', failed: '失败' }
  CLASS_NAME = { TcbdSoap: '同城速递', GnxbSoap: '国内小包', CSBSendWithSOAP: '号码百事通', StockMon: '月度库存' }
  METHOD_NAME = { order_query: '邮件查询', sendPointOrder: '获取积分订单', updatePointOrderStatus: '修改积分订单配送状态', pointOrderStatus: '积分订单状态提交', redealWithSavedOrders: '截取积分订单再处理', stock_mon_cnt: '库存月度汇总' }
  OPERATE_TYPE = {auto: '自动', manual: '手动'}

  def self.save_info(class_name, method_name,status = '1', url = nil, url_method = nil, url_request = nil, url_response = nil, type, params, info_id, operate_user)
    # binding.pry
    Rails.logger.info "class_name: #{class_name}" 
    Rails.logger.info "method_name: #{method_name}"
    Rails.logger.info "status: #{status}"
    Rails.logger.info "operate_type: #{type}"
    if info_id.blank?
      info = InterfaceInfo.new
      info.first_time = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
      info.operate_times = 1      
    else
      info = InterfaceInfo.find info_id
      info.operate_times += 1
    end

    info.class_name = class_name
    info.method_name = method_name
    if status == '1'
      info.status = "failed"
    else
      info.status = "success"
    end

    info.url = url
    info.url_method = url_method
    info.url_request = url_request
    info.url_response = url_response
    info.last_time = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    info.operate_type = type
    if operate_user.blank?
      info.operate_user = 'system'
    else
      info.operate_user = operate_user
    end
    if !params.blank?
      info.params = params.to_json
    end
    info.save!
  end

  def self.send_info(cls, method_name, params, type, info_id = nil, operate_user = nil)
    x = cls.new
    x.instance_eval do
      Rails.logger.info "************send class_name:" +cls.name+ ", method_name:"+method_name+" start*********************"
      self.send(method_name.to_sym, *params)
      Rails.logger.info "************send end*********************"
      Rails.logger.info "************save interface info class_name:" +cls.name+ ", method_name:"+method_name+" start*********************"
      InterfaceInfo.save_info(cls.name, method_name, @interface_status, nil, nil, @soap_request, @xml_file_return, type, params, info_id, operate_user)
      Rails.logger.info "***********save interface info end*********************"
      return @interface_status
    end
  end

  def self.receive_info(url_request, url_response,  type, status, info_id=nil, operate_user=nil)
      # Rails.logger.info "************receive class_name:" +cls.name+ ", method_name:"+method_name+" start*********************"
      # self.send(method_name.to_sym, *params)
      # Rails.logger.info "************receive end*********************"
      # Rails.logger.info "************save interface info class_name:" +cls.name+ ", method_name:"+method_name+" start*********************"
      InterfaceInfo.save_info(nil, nil, status, nil, nil, url_request, url_response.to_json, type, nil, info_id, operate_user)
      # Rails.logger.info "***********save interface info end*********************"
  end

  def self.resend(id, operate_user=nil)
    Rails.logger.info "resend id:" + id.to_s
    x = InterfaceInfo.find id
    if !x.blank?
      Rails.logger.info "find the interface info!"
      if x.params.blank?
        Rails.logger.info "this interface no params"
        send_info(x.class_name.constantize,x.method_name,nil,'manual',id,operate_user)
      else
        Rails.logger.info "this interface has params"
        send_info(x.class_name.constantize,x.method_name,JSON.parse(x.params),'manual',id,operate_user)
      end
    end
  end

  def self.auto_resend()
    failed_interfaces = InterfaceInfo.where("status <> ? and operate_times < ?","success",StorageConfig.config["interface_info"]['auto_resend_times'])
    failed_interfaces.each do |interface|
      InterfaceInfo.resend(interface.id,nil)
    end
  end
end
