class ProteinsController < ApplicationController
 
  require 'graph/pathFinding'
  require 'graph/graph'
  require 'listTools/enrichmentStats'
  require 'listTools/iceLogo'
  
  hobo_model_controller
  
  caches_page :show
  
  autocomplete :name, :query_scope => [:name_contains, :ac_contains]
  auto_actions :all
  show_actions :filter
   
  def index
    
    @documentations = Documentation.all.group_by(&:name)
    @perpage = 20
    quick = 0
    
    joins = Array.new
    includes = Array.new
    conditions = Array.new
    select = ['DISTINCT proteins.*']
    having = Array.new
    andconditions = Array.new
    andqueries = Array.new
    orconditions = Array.new
    orqueries = Array.new
    conditionvars = Hash.new
    
    #take the shortcut when searching for a single existing accession
    if params[:query].present?
      # if it matches the accession number schema
      match = params[:query].match(/^[A-Za-z]\w{5}(-\d)?$/).present?
      protein = Protein.find_by_ac(params[:query]) if match
    end
    if protein.present?
      redirect_to protein
    end
    
    
    # else do normal search
    if (params.keys&['query','species','function','modification','chromosome','minntermini','minctermini']).present? && !protein.present?

      #extract species
      if params[:query].present?
  
     
        match = params[:query].match(/(human|mouse|arabidopsis|yeast|ecoli)/)
        if match
          params[:query].gsub!(/((\A|\s)(human|mouse|arabidopsis|yeast|ecoli|)(\z|\s))/,'')
          case match[1]
          when 'human'
            params[:species] = 'Homo sapiens'
          when 'mouse'
            params[:species] = 'Mus musculus'
          when 'arabidopsis'
            params[:species] = 'Arabidopsis thaliana'
          when 'yeast'
            params[:species] = 'Saccharomyces cerevisiae'
          when 'ecoli'
            params[:species] = 'Esherichia coli'
          end
        end  
      end 
      
      #remove chromosome information and return error message if we try unsupported search agains chromosome
      if params[:species].present? && (params[:chromosome].present? || params[:arm].present? || params[:band].present?)
        unless params[:species] == 'Homo sapiens' || params[:species] == 'Mus musculus'
          flash[:notice] = "Search by chromosome location of the encoding gene is currently only supported for<i>Homo sapiens</i> and <i>Mus musculus</i>. Below you see results matching your search without restriction by chromosome location."
          params[:chromosome] =''
          params[:arm] =''
          params[:band] =''
        end
      end     
      
      genename = params[:query].match(/^([a-zA-Z]+)(\s|-|_|)(\d+)$/)
      variations = ['','-','_']
      if genename.present?
        namevariants = variations.map { |c| "#{genename[1]}#{c}#{genename[3]}"}.join("','")
      else
        namevariants = [params[:query]]
      end
      
      #we always join in those tables when we have a query
      if params[:query].present?
        joins << :proteinnames
      end
      
      #species  
      if params[:species].present?   
        andconditions << "species.name = '#{params[:species]}'" 
        joins <<  :species 
      end
      #//species   
      
      #modification
      if params[:modification].present?
        andconditions << "(kws_terminusmodifications.name = '#{params[:modification]}' OR kws.name = '#{params[:modification]}')"

        joins <<  {:nterms => {:terminusmodification => :kw} }
        joins <<  {:cterms => {:terminusmodification => :kw} }
      end
      #//modification       

      
      #Number of N termini
      if params[:minntermini].present?
        having << "nterminicount >= '#{params[:minntermini]}'"
        select << 'count(nterms.id) as nterminicount'
        joins << :nterms
      end
      #//ntermini 

      #Number of C termini
      if params[:minctermini].present?
        having << "cterminicount >= '#{params[:minctermini]}'"
        select << 'count(cterms.id) as cterminicount'
        joins << :cterms
      end
      #//ctermini
               
 
      #chromosome
      if params[:chromosome].present?
        andconditions << "proteins.chromosome = '#{params[:chromosome]}'" 
      end
      if params[:chromosomeposition].present?
        andconditions << "proteins.band LIKE ?"
        andqueries << "%#{params[:chromosomeposition]}%"
      end
      #//chromosome      
  
      #function
      if params[:function].present?
        if params[:function] == 'protease'
          joins << :substrates
        elsif params[:function] =='inhibitor'
          joins << :inhibited_proteases
        end
      end
      #//function    
      
      # #merops
      # if params[:query].present?
      # orconditions << "meropscode = '#{params[:query]}'"
      # orconditions << "meropsfamily = '#{params[:query]}'"
      # orconditions << "meropssubfamily = '#{params[:query]}'"
      # end
      # #//merops
      # 
      #       
      # #search for exact matches if we have a query
      # if params[:query].present?
      # if namevariants.present?
      # orconditions << "proteins.name IN ('#{namevariants}')"
      # orconditions << "proteinnames.full IN ('#{namevariants}')"
      # orconditions << "proteinnames.short IN ('#{namevariants}')"   
      # orconditions << "gns.name IN ('#{namevariants}')"  
      # orconditions << "gn_synonyms.synonym IN ('#{namevariants}')"
      # joins << {:gn => :synonyms}     
      # end 
      # orconditions << "proteins.name LIKE ?"
      # orqueries << "%#{params[:query]}%"
      # orconditions << "proteins.ac LIKE ?"
      # orqueries << "%#{params[:query]}%"
      # orconditions << "proteinnames.full LIKE ?"
      # orqueries << "%#{params[:query]}%"
      # orconditions << "proteinnames.short LIKE ?"
      # orqueries << "%#{params[:query]}%"
      # # conditionvars[:likequery] = params[:query]
      # end


      #match to proteinname, gene name, alternate names, merops family or code
      if params[:query].present?
        orconditions << "searchnames.name IN ('#{namevariants}')"
        orconditions << "searchnames.name LIKE ?"
        orqueries << "#{params[:query]}%"
        joins << :searchnames
      end

      
      querystring = Array.new
      querystring << andconditions if andconditions.present?
      querystring << "(#{orconditions.join(' OR ')})" if orconditions.present?
      querystring.compact!
      conditions << querystring.join(' AND ')
      conditions << andqueries
      conditions << orqueries
      conditions = conditions.flatten.compact
      
      res = Protein.scoped :joins => joins, :select => select.join(','), :conditions => conditions, :group => 'proteins.ac', :order => 'proteins.name' , :having => having if having.present?     
      res = Protein.scoped :joins => joins, :select => select.join(','), :conditions => conditions, :group => 'proteins.ac', :order => 'proteins.name'  unless having.present?
      
      if res.first.present? && res.last == res.first
        redirect_to res.first
      else
        hobo_index res 
      end 
    else #if no searchparams present
      hobo_index Protein, :group => 'proteins.ac', :order => 'proteins.name'
    end
  end     
  
  def show
    id = params[:id]
    #convert request into :id, :isoform, chain
#    @iso = nil
#    @chain = nil
#    if params[:id].include?('-')
#      id = params[:id].split('-').first
#      # @iso = Isoform.ac_is(params[:id]).first     
#    else
#      id = params[:id]
#      # @chain = Chain.name_is(params[:chain]).first  
#    end
    
#    if params.key?(:chain)      
#      # @chain = Chain.name_is(params[:chain]).first 
#    end
     
   
    # hobo_show @protein = Protein.id_or_ac_or_name_is(id).first  
    hobo_show @protein = Protein.find_by_ac(id)  
     
    @annotations_main = @protein.ccs.main
    @annotations_additional = @protein.ccs.additional
    @documentations = Documentation.all.group_by(&:name)
    params[:ppi].present? ? @ppi = params[:ppi] : @ppi = false


    
    @cleavages = Cleavage.apply_scopes(
    :protease_is => @protein)
    @cleavages = @cleavages.map {|x| x if x.substrate_id}.compact
    
    @cleavagesites = Cleavage.apply_scopes(
    :protease_is => @protein).*.cleavagesite
    @cleavagesites.delete(nil)
    
    @inverse_cleavages = Cleavage.apply_scopes(
    :substrate_is => @protein)
      
    @inhibitions = Inhibition.apply_scopes(
    :inhibitor_is => @protein
    )

    @inverse_inhibitions = Inhibition.apply_scopes(
    :inhibited_protease_is => @protein
    )      
      
    @cterms = Cterm.apply_scopes(
    :protein_is => @protein
    )
      
    @nterms = Nterm.apply_scopes(
    :protein_is => @protein
    )      
    
    analysis = Analysis.new(@protein,
    @cleavages,
    @cleavagesites,
    @inverse_cleavages,
    @inhibitions,
    @inverse_inhibitions,
    @cterms,
    @nterms,
    false,
    [],
    @ppi)
    @network = analysis.graph
    @simplepanel = analysis.simplepanel
    if @protein.isprotease && !@cleavagesites.nil?
      @icelogopath = analysis.icelogo      
      @heatmap = Heatmap.new(@cleavagesites)
    end
    
    
    @params = params
    evidences = @protein.inverse_cleavages.*.evidences << @protein.cleavages.*.evidences << @protein.inhibitions.*.evidences << @protein.inverse_inhibitions.*.evidences << @protein.nterms.*.evidences << @protein.cterms.*.evidences
    evidences = evidences.flatten.uniq
    @filter_directness = evidences.*.directness.flatten.uniq
    @filter_physrel = evidences.*.phys_relevance.flatten.uniq
    @filter_evidencecodes = evidences.*.evidencecodes.flatten.uniq.*.name.uniq
    @filter_confidence_type = evidences.*.confidence_type.flatten.uniq
    @filter_tissues = evidences.*.tissues.flatten.uniq.*.name.uniq
    @filter_sources = evidences.*.evidencesource.flatten.compact.uniq.*.dbname.uniq
    labs = evidences.*.lab
    labs.present? ? @filter_labs = labs.flatten.uniq.compact.sort : @filter_labs = labs
    @filter_evidences = evidences.*.name.uniq
    @filter_gocomponents = evidences.*.gocomponents.flatten.uniq.*.name.uniq
    @filter_methodologies = evidences.*.methodology.uniq
    @filter_perturbations = evidences.*.method_perturbation.uniq # added by Nik
    @filter_methodsystems = evidences.*.method_system.uniq
    @filter_methodproteasesources = evidences.*.method_protease_source.uniq
    @filter_proteaseassignmentconfidence = evidences.*.proteaseassignment_confidence.uniq
    # @filter_proteaseassignment = ['I no other proteolytic activities present', 'II proteolytic system present but abolished', 'III proteolytic system present but impaired', 'IV proteolytic system present and active','unknown']
     
  end

  def filter
    @params = params
    id = params[:id]
    #remove isofrom from ac
#    id = params[:id].split('-').first
    hobo_show @protein = Protein.id_or_ac_or_name_is(id).first  
    ids = nil
    params[:ppi].present? ? @ppi = params[:ppi] : @ppi = false
    
    #filter:
    if params[:phys_rel].present?
      paramids = Evidence.phys_relevance_in(params[:phys_rel]).*.id 
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:directness].present?
      paramids = Evidence.directness_in(params[:directness]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:confidence].present?  && params[:confidence_type].present?
      paramids = Evidence.confidence_gte(params[:confidence]).*.id
      paramids2 = Evidence.confidence_type_in(params[:confidence_type]).*.id
      ids.present? ? ids = ids & paramids & paramids2 : ids = paramids & paramids2
    end
    if params[:tissues].present?
      paramids = Evidence.tissues_tsid_in(params[:tissues]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:evidencecodes].present?
      paramids = Evidence.evidencecodes_name_in(params[:evidencecodes]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:methodologies].present?
      paramids = Evidence.methodology_in(params[:methodologies]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:perturbations].present? # added by nik
      paramids = Evidence.method_perturbation_in(params[:perturbations]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:methodsystems].present?
      paramids = Evidence.method_system_in(params[:methodsystems]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:methodproteasesources].present?
      paramids = Evidence.method_protease_source_in(params[:methodproteasesources]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:proteaseassignmentconfidences].present?
      paramids = Evidence.proteaseassignment_confidence_in(params[:proteaseassignmentconfidences]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:sources].present?
      paramids = Evidence.evidencesource_dbname_in(params[:sources]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:labs].present?
      paramids = Evidence.lab_in(params[:labs]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:evidences].present?
      paramids = Evidence.name_in(params[:evidences]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    
    ids.blank? ?  filteredevidences = nil : filteredevidences = ids.uniq

 
    @annotations_main = @protein.ccs.main
    @annotations_additional = @protein.ccs.additional
    @documentations = Documentation.all.group_by(&:name)

    @allcleavages = Cleavage.apply_scopes(
    :protease_is => @protein)
    @allcleavages = @allcleavages.map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact      
    @cleavagesites = @allcleavages.*.cleavagesite.compact
    
    
    @cleavages = @allcleavages.map {|x| x if x.substrate_id}.compact
    
    @inverse_cleavages = Cleavage.apply_scopes(
    :substrate_is => @protein).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact
      
    @inhibitions = Inhibition.apply_scopes(
    :inhibitor_is => @protein
    ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact

    @inverse_inhibitions = Inhibition.apply_scopes(
    :inhibited_protease_is => @protein
    ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact    
      
    @cterms = Cterm.apply_scopes(
    :protein_is => @protein
    ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact    
      
    @nterms = Nterm.apply_scopes(
    :protein_is => @protein
    ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact         

      
    analysis = Analysis.new(@protein,
    @cleavages,
    @cleavagesites,
    @inverse_cleavages,
    @inhibitions,
    @inverse_inhibitions,
    @cterms,
    @nterms,
    true,
    filteredevidences,
    @ppi)
    @network = analysis.graph
    @simplepanel = analysis.simplepanel

    if @protein.isprotease && !@cleavagesites.nil? && !@cleavagesites.empty?
      @icelogopath = analysis.icelogo('_filtered')      
      @heatmap = Heatmap.new(@cleavagesites)
    end
            
    
    evidences = @protein.inverse_cleavages.*.evidences << @protein.cleavages.*.evidences << @protein.inhibitions.*.evidences << @protein.inverse_inhibitions.*.evidences << @protein.nterms.*.evidences << @protein.cterms.*.evidences
    evidences = evidences.flatten.uniq
    @filter_directness = evidences.*.directness.flatten.uniq
    @filter_physrel = evidences.*.phys_relevance.flatten.uniq
    @filter_confidence_type = evidences.*.confidence_type.flatten.uniq
    @filter_evidencecodes = evidences.*.evidencecodes.flatten.uniq.*.name.sort
    @filter_tissues = evidences.*.tissues.flatten.uniq.*.name.sort
    @filter_evidencecodes = evidences.*.evidencecodes.flatten.uniq.*.name.sort
    @filter_tissues = evidences.*.tissues.flatten.uniq.*.name.sort
    @filter_sources = evidences.*.evidencesource.flatten.compact.uniq.*.dbname.sort
    labs = evidences.*.lab
    labs.present? ? @filter_labs = labs.flatten.uniq.compact.sort : @filter_labs = labs
    @filter_evidences = evidences.*.name.sort
    @filter_gocomponents = evidences.*.gocomponents.flatten.uniq.*.name.sort
    @filter_methodologies = evidences.*.methodology.uniq
    @filter_perturbations = evidences.*.method_perturbation.uniq # added by Nik
    @filter_methodsystems = evidences.*.method_system.uniq
    @filter_methodproteasesources = evidences.*.method_protease_source.uniq
    @filter_proteaseassignmentconfidence = evidences.*.proteaseassignment_confidence.uniq
    
  end 
  
  def apiget
    @params = params
    id = params[:id]
    #remove isofrom from ac
    #id = params[:id].split('-').first
    @protein = Protein.id_or_ac_or_name_is(id).first  
    ids = nil
    
    @getfeatures = params.has_key?('get_xcorr_features')
    @getevidences = params.has_key?('get_evidences')
    
    #filter:
    if params[:phys_rel].present?
      filter = true
      paramids = Evidence.phys_relevance_in(params[:phys_rel]).*.id 
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:directness].present?
      filter = true
      paramids = Evidence.directness_in(params[:directness]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:tissues].present?
      filter = true
      paramids = Evidence.tissues_ac_in(params[:tissues]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:evidencecodes].present?
      filter = true
      paramids = Evidence.evidencecodes_name_in(params[:evidencecodes]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    # if params[:methods].present?
    # paramids = Evidence.method_like(params[:methods]).*.id
    # ids.present? ? ids = ids & paramids : ids = paramids
    # end
    # if params[:sources].present?
    # paramids = Evidence.evidencesource_dbname_in(params[:sources]).*.id
    # ids.present? ? ids = ids & paramids : ids = paramids
    # end
    if params[:labs].present?
      filter = true
      paramids = Evidence.lab_in(params[:labs]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    if params[:evidences].present?
      filter = true
      paramids = Evidence.name_in(params[:evidences]).*.id
      ids.present? ? ids = ids & paramids : ids = paramids
    end
    
    ids.blank? ?  filteredevidences = nil : filteredevidences = ids.uniq

 
    @annotations_main = @protein.ccs.main
    @annotations_additional = @protein.ccs.additional
    @documentations = Documentation.all.group_by(&:name)

    unless filter
      @cleavages = Cleavage.apply_scopes(
      :protease_is => @protein)
      @cleavages = @cleavages.map {|x| x if x.substrate_id}.compact
      
      @cleavagesites = Cleavage.apply_scopes(
      :protease_is => @protein).*.cleavagesite
      @cleavagesites.delete(nil)
      
      @inverse_cleavages = Cleavage.apply_scopes(
      :substrate_is => @protein)
        
      @inhibitions = Inhibition.apply_scopes(
      :inhibitor_is => @protein
      )
  
      @inverse_inhibitions = Inhibition.apply_scopes(
      :inhibited_protease_is => @protein
      )      
        
      @cterms = Cterm.apply_scopes(
      :protein_is => @protein
      )
        
      @nterms = Nterm.apply_scopes(
      :protein_is => @protein
      )      
    else 
      #filtered
      @allcleavages = Cleavage.apply_scopes(
      :protease_is => @protein)
      @allcleavages = @allcleavages.map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact      
      @cleavagesites = @allcleavages.*.cleavagesite.compact
      
      
      @cleavages = @allcleavages.map {|x| x if x.substrate_id}.compact
      
      @inverse_cleavages = Cleavage.apply_scopes(
      :substrate_is => @protein).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact
        
      @inhibitions = Inhibition.apply_scopes(
      :inhibitor_is => @protein
      ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact
  
      @inverse_inhibitions = Inhibition.apply_scopes(
      :inhibited_protease_is => @protein
      ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact    
        
      @cterms = Cterm.apply_scopes(
      :protein_is => @protein
      ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact    
        
      @nterms = Nterm.apply_scopes(
      :protein_is => @protein
      ).map {|x| x if (filteredevidences & x.evidences.*.id).present?}.compact         
  
    end #filtered              
    
    evidences = @protein.inverse_cleavages.*.evidences << @protein.cleavages.*.evidences << @protein.inhibitions.*.evidences << @protein.inverse_inhibitions.*.evidences << @protein.nterms.*.evidences << @protein.cterms.*.evidences
    evidences = evidences.flatten.uniq
    
    respond_to do |format|
      format.xml
    end    
    
  end 
  
  def apisearch
    @perpage = 50
    count = params.has_key?('count')
    spec = params[:species]
      
    joins = Array.new
    joins << :species if params[:species].present?
    joins << :nterms if (params[:ntermini_at].present? || params[:ntermini_before].present? || params[:ntermini_after].present?)
    # joins << {:nterms => [:evidences]} if ((params[:directness].present? || params[:relevance].present? || params[:confidence_greater].present?) && (params[:ntermini_at].present? || params[:ntermini_before].present? || params[:ntermini_after].present?))
            
    joins << :cterms if (params[:ctermini_at].present? || params[:ctermini_before].present? || params[:ctermini_after].present?)
    # joins << {:cterms => [:evidences]} if ((params[:directness].present? || params[:relevance].present? || params[:confidence_greater].present?) && (params[:ctermini_at].present? || params[:ctermini_before].present? || params[:ctermini_after].present?))
      
    joins << :cleavages if (params[:cleavages_at].present? || params[:cleavages_before].present? || params[:cleavages_after].present?)
    # joins << {:cleavages => [:evidences]} if ((params[:directness].present? || params[:relevance].present? || params[:confidence_greater].present?) && (params[:cleavages_at].present? || params[:cleavages_before].present? || params[:cleavages_after].present? || params[:cleaved_by].present? || params[:cleaves].present?))

    joins << :inhibitions if (params[:inhibits].present? || params[:inhibited_by].present?)
    joins << :proteases if params[:cleaved_by].present?
    joins << :substrates if params[:cleaves].present?
    joins << :inhibitors if params[:inhibits].present?
    joins << :inhibited_proteases if params[:inhibited_by].present?
    
      
    conditions = Array.new
    conditions << "species.name = '#{params[:species]}'" if params[:species].present?
    conditions << "proteases_proteins.ac IN ('#{params[:cleaved_by]}')" if params[:cleaved_by].present?
    conditions << "substrates_proteins.ac IN ('#{params[:cleaves]}')" if params[:cleaves].present?      
    conditions << "inhibitors_proteins.ac IN ('#{params[:inhibits]}')" if params[:inhibits].present?      
    conditions << "inhibited_proteases_proteins.ac IN ('#{params[:inhibited_by]}')" if params[:inhibited_by].present?
    conditions << "cleavages.pos = '#{params[:cleavages_at]}'" if params[:cleavages_at].present?
    conditions << "cleavages.pos < '#{params[:cleavages_before]}'" if params[:cleavages_before].present?
    conditions << "cleavages.pos > '#{params[:cleavages_after]}'" if params[:cleavages_after].present?
    conditions << "nterms.pos = '#{params[:ntermini_at]}'" if params[:ntermini_at].present?
    conditions << "nterms.pos < '#{params[:ntermini_before]}'" if params[:ntermini_before].present?
    conditions << "nterms.pos > '#{params[:ntermini_after]}'" if params[:ntermini_after].present?
    conditions << "cterms.pos = '#{params[:ctermini_at]}'" if params[:ctermini_at].present?
    conditions << "cterms.pos < '#{params[:ctermini_before]}'" if params[:ctermini_before].present?
    conditions << "cterms.pos > '#{params[:ctermini_after]}'" if params[:ctermini_after].present?
    # conditions << "evidences.directness = '#{params[:directness]}'" if params[:directness].present?
    # conditions << "evidences.phys_relevance = '#{params[:relevance]}'" if params[:relevance].present?
    # conditions << "evidences.confidence >= '#{params[:confidence_greater]}'" if params[:confidence_greater].present?
      
    @proteins = Protein.all :joins => joins, :conditions => conditions.join(' AND ').to_a, :group => 'proteins.ac'  
    @proteins = Protein.all :joins => joins, :conditions => conditions.join(' AND ').to_a, :group => 'proteins.ac' unless params[:site_specific_proteases].present?
    if params[:site_specific_proteases].present? 
      conditions = Array.new
      conditions << "pos = '#{params[:position]}'"
      conditions << "proteins.ac = '#{params[:protein]}'"
      cs = Cleavage.all :joins => [:substrate], :conditions => conditions.join(' AND ').to_a 
      acs = cs.map {|c| Protein.ac_is(c.protease.ac).first.ac}.uniq.join("','")
      @proteins = Protein.all :conditions => ["ac IN ('#{acs}')"]
    end

      
    if count
      @count = @proteins.count
      @pages = (@count/@perpage).ceil
    end
    
    @proteins = @proteins.paginate :page => params[:page], :per_page => @perpage
     
    respond_to do |format|
      format.xmrequire "proteins_controller"
      l
    end    
  end
  
  def pw_input
  end
    
  def pw_output
    # if parameters are not well defined, return to input page
    if(params["start"] == "" ||  params["targets"] == "" || params["maxLength"] == "")
      puts 'else'
      render :action => 'pw_input'
    elsif(Protein.find_by_ac(params["start"].strip).nil?)
      render :text => "The start protease couldn't be found"
    else
      # CLEAN UP INPUT
      start = params["start"].strip
      targets = params["targets"].split("\n").collect{|s| {:id => s.split("\s")[0], :pos => s.split("\s")[1].to_i}}
      maxLength = params["maxLength"].to_i
      byPos = params["byPos"] == "yes"
      rangeLeft = params["rangeLeft"] == "" ? 0 : params["rangeLeft"].to_i
      rangeRight = params["rangeRight"] == "" ? 0 : params["rangeRight"].to_i
      # ORGANISMS
      nwOrg = params["network_org"]
      listOrg = params["list_org"]
      # FIND PATHS
      finder = PathFinding.new(Graph.new(nwOrg), maxLength, byPos, rangeLeft, rangeRight)
      if(nwOrg == "mouse" && listOrg == "human") # nw is mouse and list is human
        @allPaths = finder.find_all_paths_map2mouse(start, targets)
      elsif(nwOrg == "human" && listOrg == "mouse")  # nw is human and list is mouse
        @allPaths = finder.find_all_paths_map2human(start, targets)
      else
        @allPaths = finder.find_all_paths(start, targets)
      end
      @gnames = finder.paths_gene_names()                                                     # GENE NAMES FOR PROTEINS
#      domains_descriptions = ["%protease%inhibitor%", "%proteinase%inhibitor%", "%inhibitor%"]
      @allPaths =  finder.get_domain_info(["SIGNAL", "PROPEP", "ACT_SITE", "TRANSMEM"], nil)
      @sortet_subs = @allPaths.keys.sort{|x, y| @allPaths[y].size <=> @allPaths[x].size}      # SORT OUTPUT
      pdfPath = finder.make_graphviz("./public/images", @gnames)
      #Emailer.new().send(["NikolausFortelny@gmail.com"], nil)
    end 
  end
  
  def peptide_search
  end

  def peptide_search2
    @accession = params["protein"]
    @peptide = params["peptide"]
    @protein = Protein.find(:first, :conditions => [ "ac = ?", params['protein']])
    @id = @protein.id
    @sequence = @protein.sequence   
    @location = @sequence.index(@peptide)
    @location_1 = @location + 1
    @pep_nterm = Nterm.find(:all, :conditions => [ "protein_id = ? AND pos = ?", @id, @location_1])
    @pep_cleavage = Cleavage.find(:all, :conditions => ["substrate_id = ? AND pos = ?", @id, @location])
    @pep_cleaver = @pep_cleavage.collect {|c| Protein.find(:first, :conditions => ["id = ?", c.protease_id])}
    @seq_vars = Ft.find(:all, :conditions => ["protein_id = ? AND name = ?", @id, "VARIANT"])
    @seq_topo = Ft.find(:all, :conditions => ["protein_id = ? AND name = ?", @id, "TOPO_DOM"])
    @seq_mods = Ft.find(:all, :conditions => ["protein_id = ? AND name = ?", @id, "MOD_RES"])
    @evidence_nterms = Nterm2evidence.find(:all, :conditions => ["nterm_id = ?", @pep_nterms])
    @evidence_ids = @evidence_nterms.collect {|c| c.evidence_id}
    @evidences_1 = @evidence_ids.collect {|f| Evidence.find(:first, :conditions => ["id = ?", f])}
  end  
  
  def multi_peptides
  end

  def multi_peptides2
    
    nr = Dir.entries("#{RAILS_ROOT}/public/explorer").collect{|x| x.to_i}.max + 1
    dir = "#{RAILS_ROOT}/public/explorer/" + nr.to_s
    Dir.mkdir(dir)
    
    @all_input = params["all"] #string
    @input1 = @all_input.split("\n") #array 
    @chromosome = params['chromosome']
    @domain = params['domain']
    @isoform = params['isoform']
    @evidence = params['evidence']
    @proteaseWeb = params[:proteaseWeb]
    @spec = params['spec']
    @nterminal = params['nterminal'].to_i
    @cterminal = params['cterminal'].to_i

    @mainarray = []
    @input1.each {|i|   
      @q = {}
      @q[:acc] = i.split("\s").fetch(0)
      @q[:pep] = i.split("\s").fetch(1).gsub(/[^[:upper:]]+/, "")
      @q[:protein] = Protein.find(:first, :conditions => ["ac = ?", @q[:acc]])
      @q[:sequence] = @q[:protein].sequence
      @q[:species] = if @q[:protein].species_id == 1
        "Human"
      elsif @q[:protein].species_id == 2
        "Mouse"
      elsif @q[:protein].species_id == 3
        "E. Coli"
      elsif @q[:protein].species_id == 4
        "Yeast"
      elsif @q[:protein].species_id == 5
        "Arabidopsis"
      end
      @q[:sql_id] = @q[:protein].id
      @q[:all_names] = Searchname.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]])
      @q[:short_names] = Proteinname.find(:all, :conditions => ['protein_id = ? AND recommended = ?', @q[:sql_id], 1]).uniq
      @q[:location] = @q[:sequence].index(@q[:pep])
      @q[:location_1] = @q[:location] + 1
      @q[:location_range] = ((@q[:location] - @nterminal)..(@q[:location] + @cterminal)).to_a  
      @q[:upstream] = if @q[:location] < 10
        @q[:sequence][0, @q[:location]]
      else
        @q[:sequence][@q[:location] - 10, 10]
      end
      @q[:nterms] = Nterm.find(:all, :conditions => ["protein_id = ? AND pos = ?", @q[:sql_id], @q[:location_1]])
      # TODO - error when Nterms not found (the next line fails)
      # also, it actually should find N-termini in the cases I added, why doesn't it?
      if not @q[:nterms].nil?
        @q[:cleavages] = @q[:nterms].collect {|a| Cleavage.find(:all, :conditions => ["nterm_id = ?", a])} #array of arrays
      else
        @q[:cleavages] = []
      end
      if not @q[:cleavages].nil?
        # TODO what about Cleavage.find(1).protease ?
        @q[:proteases] = @q[:cleavages].collect {|a| a.collect {|b| Protein.find(:first, :conditions => ["id = ?", b.protease_id])}}
      else
        @q[:proteases] = []
      end
      @q[:domains_all] = Ft.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]])
      @q[:domains_before] = @q[:domains_all].drop_while {|a| @q[:location] > a.from.to_i}
      @q[:domains_at] = @q[:domains_all].drop_while {|a| (@q[:location] - @nterminal) <= a.from.to_i or (@q[:location] + @cterminal) >= a.to.to_i}
      @q[:domains_after] = @q[:domains_all].drop_while {|a| @q[:location] < a.to.to_i}
    
      @q[:evidence_nterms] = @q[:nterms].collect {|b| Nterm2evidence.find(:all, :conditions => ['nterm_id = ?', b])} #array of arrays
      @q[:evidence_ids] = @q[:evidence_nterms].collect { |m| m.collect {|n| n.evidence_id}} #array of arrays
      @q[:evidences] = @q[:evidence_ids].collect { |o| o.collect {|p| Evidence.find(:first, :conditions => ["id = ?", p])}} #array of arrays
      @q[:evidences_cleavages] = @q[:evidences].flatten.collect{|a| a.to_s}.delete_if {|b| !b.include?'cleavage'}
      @q[:evidence_source_ids] = @q[:evidences].collect {|a| a.collect {|b| b.evidencesource_id}}
 
      @q[:evidence_sources] = @q[:evidence_source_ids].collect {|b| b.collect {|c| Evidencesource.find(:first, :conditions => ['id = ?', c])}}
      @q[:uniprot?] = @q[:evidences].flatten.to_s.include?'inferred from uniprot'
      # @q[:source_names] = @q[:evidence_sources].collect {|c| c.dbname}
      # p @q[:evidence_sources]
      #p @q[:source_names]

      # @evidence_nterms = Nterm2evidence.find(:all, :conditions => ["nterm_id = ?", @pep_nterms])
      # @evidence_ids = @evidence_nterms.collect {|c| c.evidence_id}
      # @evidences_1 = @evidence_ids.collect {|f| Evidence.find(:first, :conditions => ["id = ?", f])}

      @q[:chr] = if @chromosome 
        [@q[:protein].chromosome, @q[:protein].band] 
      end
      @q[:transmem] = @q[:domains_all].delete_if {|a| (a.name != 'TRANSMEM') || (a.from < @q[:location_range].first) || (a.to > @q[:location_range].last)}
      print "."
      @mainarray << @q
    }
    print "\n"
    
    # ICELOGO
    IceLogo.new().terminusIcelogo(Species.find(1), @mainarray.collect{|e| e[:upstream]+":"+e[:pep]}, "#{dir}/IceLogo.svg", 4)

    # PATHFINDING
    if(@proteaseWeb == "1")
      if(not Protein.find_by_ac(params[:pw_protease].strip).nil? and params[:pw_maxPathLength].to_i > 0)
        finder = PathFinding.new(Graph.new(params[:pw_org]), params[:pw_maxPathLength].to_i, true, @nterminal, @cterminal)
        @pw_paths = finder.find_all_paths(params[:pw_protease],  @mainarray.collect{|x|  {:id => x[:acc], :pos => x[:location]} })
        @pw_gnames = finder.paths_gene_names()  # GENE NAMES FOR PROTEINS FROM PATHS
        # TODO install graphviz for this to work
        pdfPath = finder.make_graphviz(dir, @pw_gnames) # this saves the image but we need to define the path yet
      else
        p "protease not found" if Protein.find_by_ac(params[:pw_protease].strip).nil?
        p "pathlength invalid" if params[:pw_maxPathLength].to_i <= 0
        # TODO put error message on html??
      end
    end
=begin        
    # ENRICHMENT STATISTICS - needs Rserve to work!
    es = EnrichmentStats.new(@mainarray)
    es.printStatsArrayToFile("#{dir}/ProteaseStats.txt")
    es.plotProteaseCounts("#{dir}/Protease_histogram.pdf")
    es.plotProteaseSubstrateHeatmap("#{dir}/ProteaseSubstrate_matrix.pdf")
=end     
    p "DONE"
  end
 
  def trying_featurePanel
    
    p = Protein.find(1)
    
    panel = ''
    panel << "<div class='featurepanel' >"
    panel << "<div class='protein' style='width:#{p.aalen}px;'>&nbsp;"
      (p.aalen/100).to_i.times do |i|
        panel << "<div class='tickmark'>#{(i*100+100).to_s}</div>"
      end
      panel << "</div>"
    
    ## plot protein chains
    if p.fts.name_is('CHAIN').present?      
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>Chains:</div>"
      @prevto = 0
      p.fts.name_is('CHAIN').each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='chain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='<bold>stable protein chain</bold><br/>position:#{fts.from}-#{fts.to}<br/>evidence: inferred from UniProtKB<br/>#{fts.description}'>&nbsp;</a>" 
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
    end   

    ## plot nterms
    if p.nterms.present?
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>N-termini:</div>" 
      @prevto = 0
      p.nterms.each do |nt|
        if @prevto >= nt.pos.to_i-5
          panel << "<br/>"
        end
        @prevto = nt.pos.to_i
        panel << "<a class='popup nterm #{nt.terminusmodification.kw.to_s.parameterize.to_s}' style='margin-left:#{nt.pos.to_s}px;' title='<strong>N-Terminus:</strong><br/><strong>position:</strong> #{nt.pos.to_s}<br/><strong>modification:</strong> #{nt.terminusmodification.name}<br/><strong>evidence:</strong> #{nt.evidences.*.evidencecodes.*.*.*.name.flatten.join(', ')}' href='/topfind/nterms/#{nt.id}' rel='#overlay'>N</a>" 
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
    end   

    ## plot cterms
    if p.cterms.present?
      panel << "<div class='track' style='width:#{p.aalen}px;'>" 
      panel << "<div class='tracklable'>C-termini:</div>"
      @prevto = 0
      p.cterms.each do |ct|
        if @prevto >= ct.pos-5 
          panel << "<br/>"
        end
        @prevto = ct.pos 
        panel << "<a class='popup cterm #{ct.terminusmodification.kw.to_s.parameterize.to_s}' style='margin-left:#{ct.pos-23}px;' title='<strong>C-Terminus:</strong><br/><strong>position:</strong> #{ct.pos.to_s}<br/><strong>modification:</strong> #{ct.terminusmodification.name}<br/><strong>evidence:</strong> #{ct.evidences.*.evidencecodes.*.*.*.name.flatten.join(', ')}' href='/topfind/cterms/#{ct.id}' rel='#overlay'>C</a>" 
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
          end   

    ## plot cleavages
    if p.inverse_cleavages.present?
      panel << "<div class='track' style='width:#{p.aalen}px;'>" 
      panel << "<div class='tracklable'>Cleavage sites:</div>"      
      @prevto = 0      
      p.inverse_cleavages.each do |c| 
        if @prevto >= c.pos 
          panel << "<br/>"
        end
        @prevto = c.pos  
        panel << "<a class='popup inverse_cleavage' style='margin-left:#{c.pos.to_s}px;' title='Processed by: #{c.protease.shortname} @ AS #{c.pos}' href='/topfind/cleavages/#{c.id}' rel='#overlay'>&nbsp;</a>"       
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
    end

    ## plot domain like features
    unless p.domains.blank?
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>Features:</div>"
      @prevto = 0
      p.domains.each do |fts|
        flength = fts.to.to_i - fts.from.to_i 
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>"
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end   

    ## plot active features
    unless p.active_features.blank?
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>Binding & active sites:</div>"
      @prevto = 0
      p.active_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>" 
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end

    ## plot variants
    unless p.var_features.blank?
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>Sequence variations:</div>"
      @prevto = 0
      p.var_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>" 
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end

    ## plot topo features
    unless p.topo_features.blank?
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>Topology:</div>"
      @prevto = 0
      p.topo_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i 
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        cssclass = fts.name
        cssclass << "_extra" if fts.description.match('Extracellular')
        cssclass << "_intra" if fts.description.match('Cytoplasmic')
        panel << "<a class='domain #{cssclass}' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>"
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end

    ## plot modification like features
    unless p.mod_features.blank?
      panel << "<div class='track' style='width:#{p.aalen}px;'>"
      panel << "<div class='tracklable'>Modifications:</div>"
      @prevto = 0
      p.mod_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i         
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>" 
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end
    
    panel << "</div>"
    panel << '<script>jQuery(document).ready(function() {jQuery(".featurepanel a").tooltip({offset:[-10,0]}).dynamic({ bottom: { direction: "down", bounce: true } });})</script>'
    @panel = panel
  end

end