class CleavagesController < ApplicationController

  hobo_model_controller
  caches_page :show
  auto_actions :all
  index_actions :export
  show_actions :psicquicshow

  
  def new
    hobo_new do
      this.attributes = params[:cleavage] || {}
      hobo_ajax_response if request.xhr?
    end
  end
  
  def edit
    hobo_show do
      this.attributes = params[:cleavage] || {}
      hobo_ajax_response if request.xhr?
    end
  end
  
  def psicquicshow
  	#check if we come from external page like PSICQUIC > show full navigateion - else show popup style page
  	if params[:id].include?('topfind:')
      id = params[:id].split(':')[1].split('-').first
      hobo_show @cleavage = Cleavage.find_by_id(id)
    else
      id = params[:id].split('-').first
      hobo_show @cleavage = Cleavage.find_by_id(id)
    end	
  end
  
  def export
  	ids = params[:ids].split(',')
  	filename = params[:name]
    csvdata = Cleavage.generate_csv(ids)
    outfile = "#{filename}.xls"
    send_data csvdata, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{@outfile}"      
  end

  def apisearch
    @perpage = 50
    @params = params
    count = params.has_key?('count')
    spec = params[:species]
      
      joins = Array.new
      joins << {:substrate => [:species,:fts]} 
      # joins << :cleavages if (params[:cleavage_at].present? || params[:cleavage_before].present? || params[:cleavage_after].present?)
      joins << :evidences if (params[:directness].present? || params[:relevance].present? || params[:confidence_greater].present?)
    
      
      conditions = Array.new
      conditions << "species.name = '#{params[:species]}'" if params[:species].present?
      conditions << "cleavages.pos = '#{params[:cleavages_at]}'" if params[:cleavages_at].present?
      conditions << "cleavages.pos < '#{params[:cleavages_before]}'" if params[:cleavages_before].present?
      conditions << "cleavages.pos > '#{params[:cleavages_after]}'" if params[:cleavages_after].present?
      conditions << "evidences.directness = '#{params[:directness]}'" if params[:directness].present?
      conditions << "evidences.phys_relevance = '#{params[:relevance]}'" if params[:relevance].present?
      conditions << "evidences.confidence >= '#{params[:confidence_greater]}'" if params[:confidence_greater].present?
      conditions << "(cleavages.pos = fts.from AND cleavages.pos = fts.to)" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'matching')
      conditions << "(cleavages.pos >= fts.from AND cleavages.pos <= fts.to)" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'spanning')
      conditions << "cleavages.pos = fts.from" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'start')
      conditions << "cleavages.pos = fts.to" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'end')
      conditions << "fts.name = '#{params[:xcorr_feature_name]}'" if params[:xcorr_feature_name].present?
      conditions << "proteins.ac IN ('#{params[:proteins]}')" if params[:proteins].present?
      
      @results = Cleavage.all :joins => joins, :conditions => conditions.join(' AND ').to_a, :group => 'proteins.ac', :order => 'proteins.ac ASC'
          
      if count
        @count = @results.count
        @pages = (@count/@perpage).ceil
      end
    
      @results = @results.paginate :page => params[:page], :per_page => @perpage
     
    respond_to do |format|
      format.xml
    end    
  end



end
