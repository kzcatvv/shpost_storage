class StandardInterface

  def self.commodity_enter(context, business, unit)
    supplier_no = context['SUPPLIER']
    business_sku = context['BUSINESS_SKU']
    commodity_name = context['COMMODITY']
    spec = context['SPEC']
    desc = context['DESC']
    sixnine_code = context['SIXNINE']
    
    # 0428 add columns for WISH
    commodity_no = context['COMMODITY_NO']
    commodity_name_en = context['COMMODITY_EN']
    spec_en = context['SPEC_EN']
    price = context['PRICE']

    supplier = nil

    #without suppliers sync interface
    if !supplier_no.blank?
      supplier = Supplier.find_by(business_code: supplier_no, business: business)

      supplier ||= Supplier.create!(business_code: supplier_no, business: business, unit: unit)
    end

    commodity = Commodity.find_by(no: commodity_no)

    if commodity.blank?
      commodity ||= Commodity.create! name: commodity_name, name_en: commodity_name_en, unit: unit
    else
      commodity.update!( name: commodity_name, name_en: commodity_name_en)
    end
    #price = context['PRICE']

    relationship = Relationship.find_by(external_code: business_sku, business: business)
    # find_relationships(business_sku, supplier, spec, business, unit)
    

    if relationship.blank?
      specification = Specification.create! commodity: commodity, desc: desc, name: spec, name_en: spec_en, sixnine_code: sixnine_code, price: price
      relationship = Relationship.create! business: business, supplier: supplier, specification: specification, external_code: business_sku, spec_desc: spec
    else
      # relationship.upd
      relationship.specification.update! commodity: commodity, desc: desc, name: spec, name_en: spec_en, sixnine_code: sixnine_code, price: price

      relationship.update! spec_desc: spec

      if ! supplier.blank?
        relationship.update! supplier: supplier
      end
    end

    relationship
  end

  def self.order_enter(context, business, unit, storage = nil, separate = false)
    order_id = context['ORDER_ID']
    trans_sn = context['TRANS_SN']
    date = context['DATE']
    exps = context['EXPS']
    cust_name = context['CUST_NAME']
    cust_unit = context['CUST_UNIT']
    province = context['PROVINCE']
    city = context['CITY']
    county = context['COUNTY']
    addr = context['ADDR']
    mobile = context['MOBILE']
    tel = context['TEL']
    zip = context['ZIP']
    email = context['EMAIL']
    buyer_desc = context['DESC']
    qty_sum = context['QTY_SUM']
    amt_sum = context['AMT_SUM']
    exps_sum = context['EXPS_SUM']
    send_addr = context['SEND_ADDR']
    send_name = context['SEND_NAME']
    send_zip = context['SEND_ZIP']
    send_mobile = context['SEND_MOBILE']
    total_weight = context['TOTAL_WEIGHT']
    volume = context['VOLUME']
    b2b = context['B2B']

    api_key = context['API_KEY']
    exps_guid = context['EXPS_GUID']
    exps_reg = context['EXPS_REG']
    exps_type = context['EXPS_TYPE']
    country = context['COUNTRY']
    local_name = context['LOCAL_NAME']
    local_country = context['LOCAL_COUNTRY']
    local_province = context['LOCAL_PROVINCE']
    local_city = context['LOCAL_CITY']
    local_addr = context['LOCAL_ADDR']
    send_province = context['SEND_PROVINCE']
    send_city = context['SEND_CITY']

    if ! exps.blank?
      exps.downcase!

      if exps.eql?('gjxb')
        exps = "#{exps}#{(exps_reg.eql? '1') ? 'g' : 'p'}"
      end

      logistic = Logistic.find_by print_format: exps
    end

    # address
    if province.blank?
      province = parse_province addr
    end

    if city.blank?
      city = parse_city addr
    end

    if county.blank?
      county = parse_county addr
    end

    order_details = context['ORDER_DETAILS']

    # business_order_id重复check
    order = Order.where(business_order_id: order_id, business: business, unit: unit).first

    if !order.blank?
      return order
    end

    order = Order.create! business_order_id: order_id,business_trans_no: trans_sn, order_type: Order::TYPE[(b2b.eql? 'Y') ? :b2b : :b2c], customer_name: cust_name, customer_unit: cust_unit, customer_tel: tel, customer_phone: mobile, province: province, city: city, county: county, customer_address: addr, customer_postcode: zip, customer_email: email, total_price: qty_sum, total_amount: amt_sum, transport_type: exps, logistic: logistic, transport_price: exps_sum, buyer_desc: buyer_desc, business: business, unit: unit, storage: storage.blank? ? unit.default_storage : storage, status: Order::STATUS['waiting'.to_sym], pingan_ordertime: date, total_weight: total_weight, volume: volume, is_split: false, keyclientorder_id: (b2b.eql? 'Y') ? getKeycOrderID(unit,storage,'b2b') : nil, api_key: api_key, exps_guid: exps_guid, exps_reg: exps_reg, exps_type: exps_type, country: country, local_name: local_name, local_country: local_country, local_province: local_province, local_city: local_city, local_addr: local_addr, send_province: send_province, send_city: send_city, total_weight: total_weight, send_addr: send_addr, send_name: send_name, send_zip: send_zip, send_mobile: send_mobile

    undeal_details = Array.new

    order_details.each_with_index do |x, i|
      business_sku = x['BUSINESS_SKU']
      business_sku ||= x['SKU']
      next if business_sku.blank?
      qyt = x['QTY']
      next if qyt.blank?
      supplier_no = x['SUPPLIER']
      deliver_no = x['DELIVER_NO']
      spec = x['SPEC']
      desc = x['DESC']
      name = x['NAME']
      if name.blank?
        name = desc
      end
      price = x['PRICE']
      amt = x['AMT']
      from_country = x['FROM_COUNTRY']
      weight = x['weight']

      supplier = nil
      if ! supplier_no.blank?
        supplier = Supplier.find_by(business_code: supplier_no, business: business)
      end

      relationship = Relationship.find_relationships(business_sku, supplier, spec, business, unit)
    
      if relationship.blank?
        if business.no.eql? StorageConfig.config["business"]['bst_id'].to_s
          undeal_details << x
          next
        else
          order.destroy
          order = FileInterface.save_order(context, business.id, unit.id, (storage.blank? ? unit.default_storage.id : storage.id))
          # ActiveRecord::Rollback
          break
        end
      end

      # if i > 0 && separate
      #   t = Order.where(business_order_id: deliver_no, business: business, unit: unit)

      #   if !t.blank?
      #     return t
      #   end

      #   order = Order.create! business_order_id: deliver_no,business_trans_no: order_id, order_type: Order::TYPE[(b2b.eql? 'Y') ? :b2b : :b2c], customer_name: cust_name, customer_unit: cust_unit, customer_tel: tel, customer_phone: mobile, province: province, city: city, county: county, customer_address: addr, customer_postcode: zip, customer_email: email, total_price: qty_sum, total_amount: amt_sum, transport_type: exps, transport_price: exps_sum, buyer_desc: buyer_desc, business: business, unit: unit, storage: unit.default_storage, status: Order::STATUS['waiting'.to_sym], pingan_ordertime: date, total_weight: weight, volume: volume
      # end

      order.order_details.create! business_deliver_no: deliver_no, specification: relationship.specification, amount: qyt, price: price, supplier: relationship.supplier, desc: desc, name: name, from_country: from_country, weight: weight
    end

    if !undeal_details.blank?
      if undeal_details.size.eql? order_details.size
        order.destroy
      end
      context_copy = context
      undeal_details.each do |detail|
        context_copy['ORDER_DETAILS'] = Array.new << detail
        context_copy['ORDER_ID'] = detail['DELIVER_NO'].blank? ? context['ORDER_ID'] : detail['DELIVER_NO']
        order = FileInterface.save_order(context_copy, business.id, unit.id, (storage.blank? ? unit.default_storage.id : storage.id))
      end
    end

    return order 
  end

  def self.order_query(context, business, unit)
    order_no = context['ORDER_NO']
    deliver_no = context['DELIVER_NO']
    order_id = context['ORDER_ID']
    trans_sn = context['TRANS_SN']

    orders = nil
    if !order_no.blank?
      orders = Order.where(batch_no: order_no)
    end

    if orders.blank? && ! deliver_no.blank?
      orders = Order.where(tracking_number: deliver_no)
    end
    
    if orders.blank? && !order_id.blank?
      orders = Order.where(business_order_id: order_id)
    end
    
    if orders.blank? && !trans_sn.blank?
      orders = Order.where(business_trans_no: trans_sn)
    end

    return getB2Borders(orders)
  end

  def self.stock_query(context, business, unit, storage = nil)
    query_array = context['QUERY_ARRAY']
    stocks = []
    query_array.each do |x| 
      supplier_no = x['SUPPLIER']
      business_sku = x['BUSINESS_SKU']
      spec = x['SPEC']

      supplier = nil
      if !supplier_no.blank?
        supplier = Supplier.find_by(business_code: supplier_no, business: business)
      end
      
      relationship =  Relationship.find_relationships(business_sku, supplier, spec, business, unit)

      if ! relationship.blank?
        if !storage.blank?
          amount = Stock.total_stock_in_storage(relationship.specification, relationship.supplier, business, storage)
        else
          amount = Stock.total_stock_in_unit(relationship.specification, relationship.supplier, business, unit)
        end

        stocks << {'FLAG' => 'success', 'BUSINESS_SKU' => business_sku, 'SKU' => relationship.barcdoe, 'AMT' => amount}
      else
        stocks << {'FLAG' => 'failure', 'BUSINESS_SKU' => business_sku, 'CODE' => '0005', 'MSG' => '无相关商品信息'}
      end
    end
    return stocks
  end

  def self.generalise_tracking(tracking_infos)
    deliver_details = []
    if !tracking_infos.blank?
      tracking_infos.split(/\n/).each do |info|
        deliver_detail = {}
        x = info.split('#')
        if x.size == 4
          deliver_detail['DATE'] = x[0]
          deliver_detail['LOCAL'] = x[2]
          # deliver_detail['NAME'] = x[]
          deliver_detail['DELIVER_DESC'] = x[1]
        elsif x.size == 2
          deliver_detail['DATE'] = x[0]
          deliver_detail['DELIVER_DESC'] = x[1]
        end
        deliver_details << deliver_detail
      end
    end
    return deliver_details
  end

  protected
  def self.parse_province(addr)
    if addr.index '省'
      addr[0..addr.index('省')]
    end
  end

  def self.parse_city(addr)
    if addr.index '市'
      if addr.index('省') && addr.index('省') < addr.index('市')
          addr[addr.index('省')+1..addr.index('市')]
      else
          addr[0..addr.index('市')]
      end
    end
  end

  def self.parse_county(addr)
    if addr.index '区'
      if addr.index('市') && addr.index('市') < addr.index('区')
          addr[addr.index('市')+1..addr.index('区')]
      else
          addr[0..addr.index('区')]
      end
    end
  end

  def self.getB2Borders(orders)
    return_orders = []
    orders.each do |order|
      if order.has_b2b_split_orders?
        return_orders += order.get_b2b_split_orders
      else
        return_orders << order
      end
    end
    return return_orders
  end

  def self.getKeycOrderID(unit,storage,type)
    # time = Time.new
    # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
    keycorder = Keyclientorder.create(keyclient_name: "b2b auto",unit_id: unit.id,storage_id: storage.blank? ? unit.default_storage.id : storage.id,user: nil,status: "waiting",order_type: type)
    return keycorder.id
  end
end
