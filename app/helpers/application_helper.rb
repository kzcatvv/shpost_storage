module ApplicationHelper
	def product_select(obj_id)
       
       concat select(:goodstype_id, :id , Goodstype.all.map{|u| [u.name,u.id]},
       	         {:prompt => "选择"}, {"onchange" => remote_function(
       	         	:update => 'commodity_select',
       	         	:with => "'goodstype_id='+value+'&object_id=#{obj_id}'", 
                    :url => {:controller => :thirdpartcodes, :action => :select_commodities})})
       content_tag(:span,nil,id: "commodity_select")+content_tag(:span,nil,id: "specification_select")
       
    end
end
