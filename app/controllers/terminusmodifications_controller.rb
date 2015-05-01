class TerminusmodificationsController < ApplicationController

  hobo_model_controller
  caches_page :show
  auto_actions :index, :show
  
  def index
    @documentations = Documentation.all.group_by(&:name)
    terminusmodification = Terminusmodification.apply_scopes(:kw_name_is => params[:kw])
    case params[:pos]
      when 'C-terminus' 
        hobo_index terminusmodification.with_cterms
      when 'N-terminus' 
        hobo_index terminusmodification.with_nterms
      else
        hobo_index terminusmodification
    end
  end  

end
