class SpecificationAutocomController < ApplicationController
	load_and_authorize_resource :specification

	autocomplete :specification, :all_name, :extra_data => [:obj]

  def autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    #binding.pry
    business_id = params[:businessid]
    supplier_id = params[:supplierid]
    # brand_id = params[:brand_id]
    # country = params[:country]
    specifications = Specification.where('sixnine_code LIKE ? or sku LIKE ? or all_name LIKE ?', "%#{term}%","%#{term}%","%#{term}%").accessible_by(current_ability).order(:all_name).all
    #si=Relationship.joins(:specification).where('relationships.business_id= ? and relationships.supplier_id= ? and ( specifications.sixnine_code like ? or specifications.sku like ? or specifications.all_name like ? )',"#{business_id}","#{supplier_id}","%#{term}%","%#{term}%","%#{term}%").select(:specification_id)

    #specifications = Specification.where(id: si).accessible_by(current_ability).order(:all_name).all

    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end

  def br_autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    obj = params[:obj]
    business_id = obj
    supplier_id = params[:supplierid]
    #binding.pry
    si=Relationship.joins(:specification).where('relationships.business_id= ? and relationships.supplier_id= ? and ( specifications.sixnine_code like ? or specifications.sku like ? or specifications.all_name like ? )',"#{business_id}","#{supplier_id}","%#{term}%","%#{term}%","%#{term}%").select(:specification_id)
    specifications = Specification.where(id: si).accessible_by(current_ability).order(:all_name).all

    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end

  def pd_autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    #binding.pry
    obj = params[:obj]
    supplier_id = params[:supplierid]
    bid = Purchase.where('id= ?',"#{obj}").select(:business_id)
    business_id =bid[0].business_id
    si=Relationship.joins(:specification).where('relationships.business_id= ? and relationships.supplier_id= ? and ( specifications.sixnine_code like ? or specifications.sku like ? or specifications.all_name like ? )',"#{business_id}","#{supplier_id}","%#{term}%","%#{term}%","%#{term}%").select(:specification_id)

    specifications = Specification.where(id: si).accessible_by(current_ability).order(:all_name).all
      
    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end


  def ko_autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    #binding.pry
    obj = params[:obj]
    supplier_id = params[:supplierid]
    bid = Keyclientorder.where('id= ?',"#{obj}").select(:business_id)
    business_id =bid[0].business_id
    si=Relationship.joins(:specification).where('relationships.business_id= ? and relationships.supplier_id= ? and ( specifications.sixnine_code like ? or specifications.sku like ? or specifications.all_name like ? )',"#{business_id}","#{supplier_id}","%#{term}%","%#{term}%","%#{term}%").select(:specification_id)

    specifications = Specification.where(id: si).accessible_by(current_ability).order(:all_name).all
      
    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end


  def os_autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    #binding.pry
    obj = params[:obj]
    supplier_id = params[:supplierid]
    bid = Order.where('id= ?',"#{obj}").select(:business_id)
    business_id =bid[0].business_id
    si=Relationship.joins(:specification).where('relationships.business_id= ? and relationships.supplier_id= ? and ( specifications.sixnine_code like ? or specifications.sku like ? or specifications.all_name like ? )',"#{business_id}","#{supplier_id}","%#{term}%","%#{term}%","%#{term}%").select(:specification_id)

    specifications = Specification.where(id: si).accessible_by(current_ability).order(:all_name).all
      
    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end


  def ms_autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    #binding.pry
    obj = params[:obj]
    supplier_id = params[:supplierid]
    bid = ManualStock.where('id= ?',"#{obj}").select(:business_id)
    business_id =bid[0].business_id
    si=Relationship.joins(:specification).where('relationships.business_id= ? and relationships.supplier_id= ? and ( specifications.sixnine_code like ? or specifications.sku like ? or specifications.all_name like ? )',"#{business_id}","#{supplier_id}","%#{term}%","%#{term}%","%#{term}%").select(:specification_id)

    specifications = Specification.where(id: si).accessible_by(current_ability).order(:all_name).all
      
    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end
end