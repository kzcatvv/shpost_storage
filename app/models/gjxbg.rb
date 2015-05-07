class Gjxbg < ActiveRecord::Base
  def getNumber(tracking_number, num_count)
    return_no = []
    if num_count == 1
      return_no << tracking_number
    elsif num_count > 1
      return_no << tracking_number
      (2..num_count).each_with_index do |num,i|
        tracking_number = calNextTrackingNo(tracking_number)
        return_no << tracking_number 
      end
    end
    return return_no
  end

  def calNextTrackingNo(tracking_number)
    rt_num = ""
    tmpnum = tracking_number[4,9]
    chknum = checkTrackingNO( ("%06d" % (tmpnum.to_i+1) ) )
    rt_num = tracking_number[0,3]+("%06d" % (tracking_number[4,9].to_i+1) )+chknum+tracking_number[11,12]
    return rt_num
  end

  def checkTrackingNO(num)
    x = [4,2,3,5,9,7]
    num_a = num.split("")
    sum = 0
    num_a.each_with_index do |s,i|
      sum = sum + s.to_i* x[i]
    end
    sum = sum + 120
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