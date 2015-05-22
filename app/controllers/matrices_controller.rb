class MatricesController < ApplicationController
  def index
#    unless params[:updatefilter] == 'no'
#      filter_parameters = request.parameters 
#      filter_parameters.delete(:controller) 
#      filter_parameters.delete(:action)
#      filter_parameters.delete(:page) 
#      session[:filter_parameters] = filter_parameters
#    end
    
    @search = Cleavage.search(params[:searchlogic_search])
    @autocomplete = Protein.apply_scopes(
          :oss_name_is => params[:species],
          :name_or_ac_or_proteinnames_full_begins_with => params[:q])
    case params[:function]
      when 'protease'
        @autocomplete = @autocomplete.with_substrates
      when 'substrate'        
        @autocomplete = @autocomplete.with_proteases
      else
        @autocomplete.all 
    end  
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def show
#    @matrix = Matrix.all
  end
  
  def update
    params[:searchlogic_search][:protease_id_equals_any] = params[:searchlogic_search][:protease_id_equals_any].split(',')
    params[:searchlogic_search][:substrate_id_equals_any] = params[:searchlogic_search][:substrate_id_equals_any].split(',')
    @cleavages = Cleavage.search(params[:searchlogic_search])
    @cleavages ? @proteases = @cleavages.all(:group => "protease_id", :order => "protease_id ASC") : @proteases = false 
    @cleavages ? @substrates= @cleavages.all(:group => "substrate_id", :order => "substrate_id ASC") : @substrates = false
    
    respond_to do |format|
      format.js
    end
  end
end
