class SpecificationAutocomController < ApplicationController
	load_and_authorize_resource :specification

	autocomplete :specification, :all_name, :extra_data => [:obj]

  def autocomplete_specification_name
    term = params[:term]
    obj_id = params[:objid]
    # brand_id = params[:brand_id]
    # country = params[:country]
    specifications = Specification.where('sixnine_code LIKE ? or sku LIKE ? or all_name LIKE ?', "%#{term}%","%#{term}%","%#{term}%").accessible_by(current_ability).order(:all_name).all
    # binding.pry
    render :json => specifications.map { |specification| {:id => specification.id, :label => specification.all_name, :value => specification.all_name, :obj => obj_id} }

  end
end
