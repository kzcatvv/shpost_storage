class StandardInterface

  def self.commodity_enter(context, business, unit)
    supplier_no = context['SUPPLIER']
    sku = context['SKU']
    spec = context['SPEC']
    name = context['NAME']
    desc = context['DESC']
    sixnine_code = context['SIXNINE']

    supplier = nil

    if !supplier_no.blank?
      supplier = Supplier.find_supplier(supplier_no, business)

      supplier ||= Supplier.create_supplier!(supplier_no, business, unit)
    end
    
    #price = context['PRICE']

    relationship =  Relationship.find_relationships(sku, supplier, spec, business, unit)
    

    if relationship.nil?
      commodity = Commodity.create! name: name, unit: unit
      specification = Specification.create! commodity: commodity, desc: desc, name: spec, sixnine_code: sixnine_code
      relationship = Relationship.create! business: business, supplier: supplier, specification: specification, external_code: sku, spec_desc: spec
    end
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
    email = context['email']
    buyer_desc = context['DESC']
    qty_sum = context['QTY_SUM']
    amt_sum = context['AMT_SUM']
    exps_sum = context['EXPS_SUM']
    send_addr = context['SEND_ADDR']
    send_name = context['SEND_NAME']
    send_zip = context['SEND_ZIP']
    send_mobile = context['SEND_MOBILE']
    weight = context['WEIGHT']
    volume = context['VOLUME']
    b2b = context['B2B']

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

    order = Order.create! business_order_id: order_id,business_trans_no: trans_sn, order_type: Order::TYPE[(b2b.eql? 'Y') ? :b2b : :b2c], customer_name: cust_name, customer_unit: cust_unit, customer_tel: tel, customer_phone: mobile, province: province, city: city, county: county, customer_address: addr, customer_postcode: zip, customer_email: email, total_price: qty_sum, total_amount: amt_sum, transport_type: exps, transport_price: exps_sum, buyer_desc: buyer_desc, business: business, unit: unit, storage: storage.blank? ? unit.default_storage : storage, status: Order::STATUS['waiting'.to_sym], pingan_ordertime: date, total_weight: weight, volume: volume, is_split: false, keyclientorder_id: (b2b.eql? 'Y') ? getKeycOrderID(unit,storage,'b2b') : nil

    order_details.each_with_index do |x, i|
      sku = x['SKU']
      next if sku.blank?
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

      supplier = nil
      if !supplier_no.blank?
        supplier = Supplier.find_supplier(supplier_no, business)
      end

      relationship = Relationship.find_relationships(sku, supplier, spec, business, unit)
    
      if relationship.nil?
        order.delete
        order = FileInterface.save_order(context, business.id, unit.id, (storage.blank? ? unit.default_storage.id : storage.id))
        # ActiveRecord::Rollback
        break
      end

      # if i > 0 && separate
      #   t = Order.where(business_order_id: deliver_no, business: business, unit: unit)

      #   if !t.blank?
      #     return t
      #   end

      #   order = Order.create! business_order_id: deliver_no,business_trans_no: order_id, order_type: Order::TYPE[(b2b.eql? 'Y') ? :b2b : :b2c], customer_name: cust_name, customer_unit: cust_unit, customer_tel: tel, customer_phone: mobile, province: province, city: city, county: county, customer_address: addr, customer_postcode: zip, customer_email: email, total_price: qty_sum, total_amount: amt_sum, transport_type: exps, transport_price: exps_sum, buyer_desc: buyer_desc, business: business, unit: unit, storage: unit.default_storage, status: Order::STATUS['waiting'.to_sym], pingan_ordertime: date, total_weight: weight, volume: volume
      # end

      order.order_details.create! business_deliver_no: deliver_no, specification: relationship.specification, amount: qyt, price: price, supplier: relationship.supplier, desc: desc, name: name
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

    if !deliver_no.blank?
      orders ||= Order.where(tracking_number: deliver_no)
    end
    
    if !order_id.blank?
      orders ||= Order.where(business_order_id: order_id)
    end
    
    if !trans_sn.blank?
      orders ||= Order.where(business_trans_no: trans_sn)
    end

    return orders
  end

  def self.stock_query(context, business, unit, storage = nil)
    query_array = context['QUERY_ARRAY']
    stock_array = []
    query_array.each do |x| 
      supplier_no = x['SUPPLIER']
      sku = x['SKU']
      spec = x['SPEC']

      supplier = nil
      if !supplier_no.blank?
        supplier = Supplier.find_supplier(supplier_no, business)
      end
      
      relationship =  Relationship.find_relationships(sku, supplier, spec, business, unit)

      if relationship.nil?
        amount = 0
      else
        if !storage.nil?
          amount = Stock.total_stock_in_storage(relationship.specification, relationship.supplier, business, storage)
        else
          amount = Stock.total_stock_in_unit(relationship.specification, relationship.supplier, business, unit)
        end
      end

      stock_array << {'SKU' => sku,'AMT' => amount}
    end
    return stock_array
  end

  def self.generalise_tracking(tracking_infos)
    if !tracking_infos.blank?
      deliver_details = []
      tracking_infos.split(/\n/).each do |info|
        deliver_detail = {}
        x = info.split('#')
        if x.size == 4
          deliver_detail['DATE'] = x[0]
          deliver_detail['LOCAL'] = x[2]
          # deliver_detail['NAME'] = x[]
          deliver_detail['DESC'] = x[1]
        elsif x.size == 2
          deliver_detail['DATE'] = x[0]
          deliver_detail['DESC'] = x[1]
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


  def self.getKeycOrderID(unit,storage,type)
    # time = Time.new
    # batch_no = time.year.to_s+time.month.to_s.rjust(2,'0')+time.day.to_s.rjust(2,'0')+Keyclientorder.count.to_s.rjust(5,'0')
    keycorder = Keyclientorder.create(keyclient_name: "b2b auto",unit_id: unit.id,storage_id: storage.blank? ? unit.default_storage.id : storage.id,user: nil,status: "waiting",order_type: type)
    return keycorder.id
  end
end
