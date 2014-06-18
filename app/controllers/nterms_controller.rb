class NtermsController < ApplicationController

  hobo_model_controller

  caches_page :show
  auto_actions :all

  
  def export
    ids = params[:ids].split(',')
    filename = params[:name]
    csvdata = Nterm.generate_csv(ids)
    outfile = "#{filename}.xls"
    send_data csvdata, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{@outfile}"      
  end

  def index
    @perpage = 50
    @params = params
    @documentations = Documentation.all.group_by(&:name)    
    count = params.has_key?('count')
    spec = params[:species]
      
      joins = Array.new
      joins << {:protein => [:species]}
      joins << {:terminusmodification => :kw} if params[:modification].present?
      joins << :evidences if (params[:directness].present? || params[:relevance].present? || params[:confidence_greater].present?)
    
      
      conditions = Array.new
      conditionsvars = Hash.new
      conditions << "nterms.pos = 'z'" unless (params.keys&['query','species','seqstart','seqregexp','pos','protein']).present?
      conditions << "proteins.ac = '#{params[:protein]}'"  if params[:protein].present?
      conditions << "species.name = '#{params[:species]}'" if params[:species].present?      
      conditions << "nterms.seqexcerpt LIKE :seqstart" if params[:seqstart].present?      
        conditionsvars[:seqstart] = params[:seqstart]+'%' if params[:seqstart].present?     
      conditions << "nterms.seqexcerpt REGEXP :seqregexp" if params[:seqregexp].present?      
        conditionsvars[:seqregexp] = params[:seqregexp] if params[:seqregexp].present? 
      conditions << "kws.name = '#{params[:modification]}'" if params[:modification].present?
      if params[:postype].present?
        case params[:postype]
          when 'at'
             conditions << "nterms.pos = '#{params[:pos]}'" if params[:pos].present?
          when 'before'
            conditions << "nterms.pos < '#{params[:pos]}'" if params[:pos].present?
          when 'after'
            conditions << "nterms.pos > '#{params[:pos]}'" if params[:pos].present?
        end
      end
      @results = Nterm.scoped :joins => joins, :conditions => [conditions.join(' AND '), conditionsvars ], :group => 'nterms.id', :order => 'nterms.pos ASC'
          
      if count
        @count = @results.count
        @pages = (@count/@perpage).ceil
      end
      @nterms = @results
      
      # @nterms = @results.paginate :page => params[:page], :per_page => @perpage
     
    hobo_index @nterms
  end

  def apisearch
    @perpage = 50
    @params = params
    count = params.has_key?('count')
    spec = params[:species]
      
      joins = Array.new
      joins << {:protein => [:species,:fts]} 
      joins << :evidences if (params[:directness].present? || params[:relevance].present? || params[:confidence_greater].present?)
    
      
      conditions = Array.new
      conditions << "species.name = '#{params[:species]}'" if params[:species].present?
      conditions << "nterms.pos = '#{params[:ntermini_at]}'" if params[:ntermini_at].present?
      conditions << "nterms.pos < '#{params[:ntermini_before]}'" if params[:ntermini_before].present?
      conditions << "nterms.pos > '#{params[:ntermini_after]}'" if params[:ntermini_after].present?
      conditions << "evidences.directness = '#{params[:directness]}'" if params[:directness].present?
      conditions << "evidences.phys_relevance = '#{params[:relevance]}'" if params[:relevance].present?
      conditions << "evidences.confidence >= '#{params[:confidence_greater]}'" if params[:confidence_greater].present?
      conditions << "(nterms.pos = fts.from AND nterms.pos = fts.to)" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'matching')
      conditions << "(nterms.pos >= fts.from AND nterms.pos <= fts.to)" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'spanning')
      conditions << "nterms.pos = fts.from" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'start')
      conditions << "nterms.pos = fts.to" if (params[:xcorr_feature].present? && params[:xcorr_feature] == 'end')
      conditions << "fts.name = '#{params[:xcorr_feature_name]}'" if params[:xcorr_feature_name].present?
      conditions << "proteins.ac IN ('#{params[:proteins]}')" if params[:proteins].present?
      
      @results = Nterm.all :joins => joins, :conditions => conditions.join(' AND ').to_a, :group => 'proteins.ac', :order => 'proteins.ac ASC'
          
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
