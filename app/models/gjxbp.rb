class Gjxbp < ActiveRecord::Base

  def self.getHotTrackingNumber(logistic_id,storage, num_count)
    return_no = []
    storage_id = storage.id
    sequence_no = SequenceNo.find_by(storage_id:storage_id,logistic_id:logistic_id) if !logistic_id.blank?
    snumber = sequence_no.end_no if !sequence_no.blank?
    if !snumber.blank?
      if num_count == 1
        return_no << calNextTrackingNo(snumber)
      elsif num_count > 1
        (1..num_count).each_with_index do |num,i|
          tracking_number = calNextTrackingNo(snumber)
          snumber=(snumber.to_i+1).to_s
          return_no << tracking_number 
        end
      end
      SequenceNo.update(sequence_no.id,end_no:snumber)
    end
    return return_no
  end

  def self.calNextTrackingNo(tracking_number)
    rt_num = ""
    chknum = checkTrackingNO( ("%07d" % (tracking_number.to_i+1) ) )
    rt_num = "018"+("%07d" % (tracking_number.to_i+1) )+chknum
    return rt_num
  end

  def self.checkTrackingNO(num)
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
