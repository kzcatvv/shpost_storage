json.array!(@orders) do |order|
  json.extract! order, :id, :no, :order_type, :has_invoice, :cust_id, :cust_name, :cust_phone, :cust_mobilephone, :cust_address, :cust_postcode, :cust_email, :good_weight, :good_sum, :good_amount, :trans_type, :trans_sum, :pay_type, :status, :buyer_desc, :seller_desc
  json.url order_url(order, format: :json)
end
