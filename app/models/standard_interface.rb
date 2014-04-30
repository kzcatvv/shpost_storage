class StandardInterface
  def self.commodity_enter(context, business, unit)
    supplier_no = context['SUPPLIER']
    sku = context['SKU']
    spec = context['SPEC']
    name = context['NAME']
    desc = context['DESC']

    supplier = nil

    if !supplier_no.blank?
      supplier = Supplier.find_supplier(supplier_no, business)

      supplier ||= Supplier.create_supplier!(supplier_no, business, unit)
    end
    
    #price = context['PRICE']

    relationship =  Relationship.find_relationship(sku, supplier, spec, business, unit)
    

    if relationship.nil?
      commodity = Commodity.create! name: name, unit: unit, no: 'need_to_edit'
      specification = Specification.create! commodity: commodity, desc: desc, name: spec, sku: 'need_to_edit', sixnine_code: 'need_to_edit'
      relationship = Relationship.create! business: business, supplier: supplier, specification: specification, external_code: sku, spec_desc: spec
    end
  end

  def self.order_enter(context, business, unit)
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
    desc = context['DESC']
    qty_sum = context['QTY_SUM']
    amt_sum = context['AMT_SUM']
    exps_sum = context['EXPS_SUM']
    send_addr = context['SEND_ADDR']
    send_name = context['SEND_NAME']
    send_zip = context['SEND_ZIP']
    send_mobile = context['SEND_MOBILE']

    if province.blank?
      province = parse_province addr
    end

    if city.blank?
      city = parse_city addr
    end

    if county.blank?
      county = parse_county addr
    end

    order = Order.create! business_order_id: order_id,business_trans_no: trans_sn, order_type: Order::TYPE['b2c'], customer_name: cust_name, customer_unit: cust_unit, customer_tel: tel, customer_phone: mobile, province: province, city: city, county: county, customer_address: addr, customer_postcode: zip, customer_email: email, total_price: qty_sum, total_amount: amt_sum, transport_type: exps, transport_price: exps_sum, buyer_desc: desc, business: business, unit: unit, storage: unit.default_storage, status: Order::STATUS['waiting']

    order_details = context['ORDER_DETAILS']

    order_details.each do |x|
      sku = x['SKU']
      next if sku.blank?
      qyt = x['QTY']
      next if qyt.blank?
      supplier_no = x['SUPPLIER']
      deliver_no = x['DELIVER_NO']
      spec = x['SPEC']
      desc = x['DESC']
      name = x['NAME']
      price = x['PRICE']
      amt = x['AMT']

      supplier = nil
      if !supplier_no.blank?
        supplier = Supplier.find_supplier(supplier_no, business)
      end

      relationship = Relationship.find_relationship(sku, supplier, spec, business, unit)
    
      next if relationship.nil?

      OrderDetail.create! business_deliver_no: deliver_no, specification: relationship.specification, amount: qyt, price: price, supplier: relationship.supplier, order: order, desc: desc
    end 

    return order 
  end

  def self.order_query(context, business, unit)
    order_no = context['ORDER_NO']
    deliver_no = context['DELIVER_NO']
    order_id = context['ORDER_ID']
    trans_sn = context['TRANS_SN']

    order = nil
    if !deliver_no.blank?
      order = ORDERDETAIL.find_by_business_deliver_no deliver_no
    end

    order ||= Order.find_by_no order_no
    order ||= Order.find_by_business_order_id order_id
    order ||= Order.find_by_business_trans_no trans_sn
  end

  def self.stock_query(context, business, unit)
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
      
      relationship =  Relationship.find_relationship(sku, supplier, spec, business, unit)

      if relationship.nil?
        amount = 0
      else
        amount = Stock.total_stock_in_unit(relationship.specification, relationship.supplier, business, unit)
      end

      stock_array << {'SKU' => sku,'AMT' => amount}
    end
    return stock_array
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
end
