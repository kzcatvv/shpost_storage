class Gjxbp < ActiveRecord::Base

  def self.getHotTrackingNumber(logistic_id,storage, num_count)
    return_no = []
    storage_id = storage.id
    sequence_no = SequenceNo.find_by(storage_id:storage_id,logistic_id:logistic_id) if !logistic_id.blank?
    snumber = sequence_no.start_no if !sequence_no.blank?
    enumber = sequence_no.end_no if !sequence_no.blank?
    storage_no = sequence_no.storage_no.first(3) if !sequence_no.blank?

    if !snumber.blank? and !enumber.blank?
      if num_count<=(enumber-snumber+1)
        (1..num_count).each_with_index do |num,i|
          tracking_number = calTrackingNo(snumber,storage_no)
          snumber=snumber+1
          return_no << tracking_number 
        end
      end
      SequenceNo.update(sequence_no.id,start_no:snumber)
    end
    return return_no
  end

  def self.calTrackingNo(snumber,storage_no)
    rt_num = ""
    chknum = checkTrackingNO( ("%07d" % snumber) )
    rt_num = storage_no+("%07d" % snumber)+chknum
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
