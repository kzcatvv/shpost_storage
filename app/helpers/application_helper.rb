module ApplicationHelper

	def product_select(obj_id)
       
       concat  select_tag("ajax_goodstype_id", options_for_select(Goodstype.accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择") ))
       concat hidden_field_tag('ajax_object_id', obj_id)
       span_commodity_select+span_specification_select(obj_id)

    end

    def span_commodity_select
       content_tag(:span) do
       	concat select_tag("ajax_commodity_id", options_for_select(Commodity.accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择") ))
       end
    end

    def span_specification_select(obj_id)
    	content_tag(:span) do
       	 concat select(obj_id.to_sym,"specification_id", Specification.accessible_by(current_ability).map{|u| [u.name,u.id]},{:prompt => "请选择"})
      end
    end
end
