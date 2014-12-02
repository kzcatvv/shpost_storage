module ApplicationHelper

	  def product_select(obj_id)
       
       concat  select("goodstype","id", Goodstype.accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择") )
       concat hidden_field_tag('ajax_object_id', obj_id)
       span_commodity_select+span_specification_select(obj_id)

    end

    def span_commodity_select
       content_tag(:span) do
       	concat select("commodity","id", Commodity.accessible_by(current_ability).map{|u| [u.name,u.id]}.insert(0,"请选择") )
       end
    end

    def span_specification_select(obj_id)
    	content_tag(:span) do
       	 concat select(obj_id.to_sym,"specification_id", Specification.accessible_by(current_ability).map{|u| [u.name,u.id]},{:prompt => "请选择"})
      end
    end


    def product_select_autocom(obj_id)
       
       concat text_field_tag('specification_name',@spname, 'data-autocomplete' => "/specification_autocom/autocomplete_specification_name?objid=#{obj_id}" )
       hidden_field(obj_id.to_sym,"specification_id");
    end

    def sp_product_select_autocom(obj_id,obj)
       
       concat text_field_tag('specification_name',@spname, 'data-autocomplete' => "/specification_autocom/sp_autocomplete_specification_name?objid=#{obj_id}&obj=#{obj}")
       hidden_field(obj_id.to_sym,"specification_id");
    end

    def br_product_select_autocom(obj_id,obj)
       
       concat text_field_tag('specification_name',@spname, 'data-autocomplete' => "/specification_autocom/br_autocomplete_specification_name?objid=#{obj_id}&obj=#{obj}")
       hidden_field(obj_id.to_sym,"specification_id");
    end

    
end
