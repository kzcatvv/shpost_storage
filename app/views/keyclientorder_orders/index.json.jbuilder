json.array!(@orders) do |order|
  json.extract! order, :id, :no, :order_type, :need_invoice, :customer_name, :customer_unit, :customer_phone, :customer_mobilephone,:province,:city, :customer_address, :customer_postcode, :customer_email, :total_weight, :total_price, :total_amount, :transport_type, :transport_price, :pay_type, :status, :buyer_desc, :seller_desc,:business_id,:unit_id,:storage_id,:keyclientorder_id
  json.url order_url(order, format: :json)
end
