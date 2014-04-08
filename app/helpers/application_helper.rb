module ApplicationHelper

	def product_select(obj_id)
       
       concat select(:goodstype_id, nil , Goodstype.all.map{|u| [u.name,u.id]},
       	         {:prompt => "选择"}, data: { remote: true,
       	         	:url => "/thirdpartcodes/select_commodities",
       	         	update: "commodity_select" 
                    })
       content_tag(:span,nil,id: "commodity_select")+content_tag(:span,nil,id: "specification_select")
       
    end
end
