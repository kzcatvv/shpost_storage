class FileInterface
  def self.save_order(order_context, business_id, unit_id)
    direct = "#{Rails.root}/upload/orders/"
    if !file_exist(direct + "*" + order_context['ORDER_ID'] + "*")
      file_name = "#{Time.now.to_f}_" + order_context['ORDER_ID']
      file_content = order_context.to_json << "\n" << business_id.to_s << "\n" << unit_id.to_s
      write_file(direct + file_name,file_content)
      return file_name
    else
      return order_context['ORDER_ID']
    end
  end

  def self.file_exist(file_path)
    Dir[file_path].size > 0
  end

  def self.read_order_file(file_path)
    file = File.open(file_path,"r")
    ary = file.readlines
  end

  def self.write_file(file_path, file_content)
    File.open(file_path, "wb") do |f|
      f.write(file_content)
    end
  end

  def self.delete_file(file_path)
    File.delete(file_path)
  end
end
