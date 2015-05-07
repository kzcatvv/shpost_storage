class Gjxbp < ActiveRecord::Base
  def getHotTrackingNumber(logistic_id, num_count)
    return_no = []
    storage_id = current_storage.id
    sequence_no = SequenceNo.find_by(storage_id:storage_id,logistic_id:logistic_id) if !logistic_id.blank?
    tracking_number = sequence_no.end_no if !sequence_no.blank?
    tracking_number = (tracking_number.to_i+1).to_s
    if !tracking_number.blank?
      if num_count == 1
        return_no << tracking_number
      elsif num_count > 1
        return_no << tracking_number
        (2..num_count).each_with_index do |num,i|
          tracking_number = calNextTrackingNo(tracking_number)
          return_no << tracking_number 
        end
      end
      SequenceNo.update(sequence_no.id,end_no:tracking_number)
    end
    return return_no
  end

  def calNextTrackingNo(tracking_number)
    rt_num = ""
    tmpnum = tracking_number[3,9]
    chknum = checkTrackingNO( ("%07d" % (tmpnum.to_i+1) ) )
    rt_num = tracking_number[0,2]+("%07d" % (tracking_number[3,9].to_i+1) )+chknum
    return rt_num
  end

  def checkTrackingNO(num)
    x = [6,4,2,3,5,9,7]
    num_a = num.split("")
    sum = 0
    num_a.each_with_index do |s,i|
      sum = sum + s.to_i* x[i]
    end
    sum = sum + 64
    r = sum % 11
    case r
      when 0
        return "5"
      when 1
        return "0"
      else
        return (11 - r).to_s
    end
  end

end