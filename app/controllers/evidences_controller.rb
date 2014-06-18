class EvidencesController < ApplicationController

  hobo_model_controller

  autocomplete :import_evidence_name do
    hobo_completions :name, Evidence.owner_is(current_user)
  end

  auto_actions :all, :except => :destroy
  
  def new
    @documentations = Documentation.all.group_by(&:name)
  	hobo_new
  end
  
  def create
  	hobo_create :redirect => '/topfind/contribute'
  end
 
  
  def export
  	ids = params[:ids].split(',')
  	filename = params[:name]
    csvdata = Evidence.generate_csv(ids)
    outfile = "#{filename}.xls"
    send_data csvdata, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{@outfile}"      
  end  

end
