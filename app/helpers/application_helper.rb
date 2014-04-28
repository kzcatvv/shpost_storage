module ApplicationHelper

	def product_select(obj_id)
       
       concat  select_tag("ajax_goodstype_id", options_from_collection_for_select(Goodstype.all, "id", "name"),
                 {:prompt => "请选择"})
       concat hidden_field_tag('ajax_object_id', obj_id)
       span_commodity_select+span_specification_select(obj_id)

    end

    def span_commodity_select
        content_tag(:span) do
       	concat select_tag("ajax_commodity_id", @commodities,{:prompt => "请选择"})
       end
    end

    def span_specification_select(obj_id)
    	  content_tag(:span) do
       	concat select(obj_id.to_sym,"specification_id", " ",{:prompt => "请选择"})
       end
    end
end
