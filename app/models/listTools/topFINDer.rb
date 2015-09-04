class TopFINDer
  def initialize()    
  end
  
  def analyze(params, label)
      
    ###
    ### LOADING REQUIRED PACKAGES
    ###
    require 'graph/pathFinding'
    require 'graph/graph'
    require 'listTools/enrichmentStats'
    require 'listTools/iceLogo'
    require 'listTools/venn'
    require 'listTools/emailer'
    
    system("Rscript #{RAILS_ROOT}/Rserve_Startup.R")
    
    ###
    ### Creating directories
    ###
    nr = Dir.entries("#{RAILS_ROOT}/public/explorer").collect{|x| x.to_i}.max + 1
    dir = "#{RAILS_ROOT}/public/explorer/" + nr.to_s 
    Dir.mkdir(dir)
    fileDir = dir + "/#{label}"
    Dir.mkdir(fileDir)
  
    ###
    ### Parsing Parameters
    ###
    @all_input = params["all"].strip #string
    @input1 = @all_input.split("\n") #array 
    @chromosome = params['chromosome']
    @domain = params['domain']
    @evidence = params['evidence']
    @proteaseWeb = params[:proteaseWeb]
    @proteaseStats = params[:stats]
    @spec = params['spec']
    @nterminal = params['nterminal'].to_i
    @cterminal = params['cterminal'].to_i
    @mainHash = {}
    @nterms = (params[:nterms] == "nterms")

    # create a uniquifyable list of ids
    @orderedInput = @input1.collect {|i| i.gsub("_", "")}.collect{|x| x.gsub("\s", "_")}.collect{|x| x.gsub("\t", "_")}
    @uniqueInput = @orderedInput.uniq
    
    ###
    ### Go through input, get information, line by line
    ###
    print "Analyzing #{@uniqueInput.length} unique peptides of a list of #{@orderedInput.length}\n"
    @uniqueInput.each{|i|
      print "." 
      @q = {}
      iSplit = i.split("_")
      if iSplit.length < 2
        @q[:found] = false
        @q[:acc] = i
        @q[:full_pep] = "incomplete row"
        @mainHash[i] = @q
        next
      else
        @q[:acc] = iSplit.fetch(0)
        @q[:pep] = iSplit.fetch(1).gsub(/^.{1}\./,"").gsub(/\..{1}$/,"").gsub(/[^[:upper:]]+/, "")
        @q[:full_pep] = iSplit.fetch(1)
        @q[:protein] = if Protein.find(:first, :conditions => ["ac = ?", @q[:acc]]) != nil
          Protein.find(:first, :conditions => ["ac = ?", @q[:acc]])
        else
        end
      end
      
      # get location if protein is found
      if not @q[:protein].present? or @q[:pep] == ""
        @q[:found] = false
        @mainHash[i] = @q
        next
      else
        @q[:sequence] = @q[:protein].sequence
        match_peptide = @q[:pep]
        match_sequence = @q[:sequence]
        if(!params[:IleLeu].nil?)
          match_peptide = match_peptide.gsub(/I/, "L")
          match_sequence = match_sequence.gsub(/I/, "L")
        end
        if(!params[:glx].nil?)
          match_peptide = match_peptide.gsub(/Z/, "Q")
          match_sequence = match_sequence.gsub(/Z/, "Q")
        end
        if(!params[:asx].nil?)
          match_peptide = match_peptide.gsub(/B/, "N")
          match_sequence = match_sequence.gsub(/B/, "N") 
        end
        if @nterms
          @q[:location_C] = match_sequence.index(match_peptide)
        else
          @q[:location_C] = match_sequence.index(match_peptide) 
          if not @q[:location_C].nil?
            @q[:location_C] = @q[:location_C] + @q[:pep].length 
          end
        end
      end

      # is location found otherwise don't process
      if @q[:location_C].nil?
        @q[:found] = false
        @mainHash[i] = @q
        next
      end

      if @q[:protein].present? and @q[:location_C] >= 0
        @q[:found] = true
      end

      @q[:location_C_range] = ((@q[:location_C] - @nterminal)..(@q[:location_C] + @cterminal)).to_a  
      @q[:location_N_range] = @q[:location_C_range].collect{|x| x + 1}
      if @q[:location_C] < 10
        @q[:upstream] =  @q[:sequence][0, @q[:location_C]]
      else
        @q[:upstream] =  @q[:sequence][@q[:location_C] - 10, 10]
      end
      if (@q[:sequence].length - @q[:location_C]) < 10
        @q[:downstream] =  @q[:sequence][@q[:location_C], @q[:sequence].length - @q[:location_C]]
      else
        @q[:downstream] =  @q[:sequence][@q[:location_C], 10]
      end        
          
      @q[:chr] = if @chromosome 
        [@q[:protein].chromosome, @q[:protein].band] 
      end
    
      @q[:species] = @q[:protein].species.common_name
      
      @q[:sql_id] = @q[:protein].id
      # not used any more (names are now taken from the protein)
      # @q[:all_names] = Searchname.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]]).uniq
      
      # NTERMINI AND EVIDENCES
      if @nterms
        @q[:termini] = Nterm.find(:all, :conditions => ["protein_id = ?", @q[:sql_id]]).select{|n| @q[:location_N_range].include? n.pos}
        @q[:evidences] =  @q[:termini].collect {|b| Nterm2evidence.find(:all, :conditions => ['nterm_id = ?', b.id])}.flatten.collect{|n2e| n2e.evidence}
      else
        @q[:termini] = Cterm.find(:all, :conditions => ["protein_id = ?", @q[:sql_id]]).select{|n| @q[:location_C_range].include? n.pos}
        @q[:evidences] =  @q[:termini].collect {|b| Cterm2evidence.find(:all, :conditions => ['cterm_id = ?', b.id])}.flatten.collect{|n2e| n2e.evidence}
      end
      @q[:evidences] = @q[:evidences].select{|e| !e.nil?}      
      @q[:uniprot] =[]
      @q[:ensembl] =[]
      @q[:tisdb] =[]
      @q[:isoforms] =[]
      @q[:otherEvidences] =[]
      @q[:evidences].each{|e|
        if e.evidencesource.nil?
          if (e.name =~ /Inferred from cleavage\-/).nil?
            @q[:otherEvidences] << e
          end
        elsif e.evidencesource.dbname == "UniProtKB"
          @q[:uniprot] << e 
        elsif e.evidencesource.dbname == "Ensembl"
          @q[:ensembl] << e 
        elsif e.evidencesource.dbname == "TISdb"
          @q[:tisdb] << e 
        elsif e.evidencecodes.collect{|s| s.code}.include? "TopFIND:0000002"
          if @nterms and @q[:location_C] > 3
            @q[:isoforms] << e
          elsif not @nterms and @q[:location_C] < (@q[:protein].aalen-1)
            @q[:isoforms] << e
          end
        else
        end
      }
            
      # CLEAVAGES
      @q[:cleavages] = Cleavage.find(:all, :conditions => ["substrate_id = ?", @q[:sql_id]])
      
      if not @q[:cleavages].nil?
        @q[:cleavages] = @q[:cleavages].select{|c| @q[:location_C_range].include? c.pos}
        @q[:proteases] = @q[:cleavages].collect {|c| c.protease}
      else
        @q[:proteases] = []
      end
      
      # DOMAINS
      @q[:domains_all] = Ft.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]])
      @q[:domains_all] = @q[:domains_all].select{|d| !["HELIX", "STRAND", "TURN", "CONFLICT", "VARIANT", "VAR_SEQ"].include? d.name} # FILTER OUT SOME UNINFORMATIVE ONES
      @q[:domains_before] = @q[:domains_all].select {|a| a.to.to_i <= @q[:location_C]}
      @q[:domains_after] = @q[:domains_all].select {|a| a.from.to_i >= @q[:location_C] + 1 }
      @q[:domains_at] = @q[:domains_all].select {|a| 
        (a.from.to_i <= @q[:location_C] and a.to.to_i >= @q[:location_C] + 1)
      }
        
      # SIGNAL, PROPEPTIDE AND SHEDDING
      # Signal peptide
      sigs = @q[:domains_all].select{|d| d.name == "SIGNAL"}
      if sigs.length == 0
        @q[:SigPDistance] = ""
      else
        @q[:SigPDistance] = (@q[:location_C] - sigs.collect{|d| d.to}.max().to_i)
      end
      # Propeptide
      prop = @q[:domains_all].select{|d| d.name == "PROPEP"}
      if prop.length == 0
        @q[:ProPDistance] = ""
      else
        @q[:ProPDistance] = (@q[:location_C] - prop.collect{|d| d.to}.max().to_i)
      end
      # shedding
      tmd = @q[:domains_all].select{|d| d.name == "TRANSMEM"}
      if tmd.length == 0
        @q[:ShedDistance] = ""
      else
        @q[:ShedDistance] = (@q[:location_C] - tmd.collect{|d| d.to}.max().to_i)
      end
      # transit peptides
      transit = @q[:domains_all].select{|d| d.name == "TRANSIT"}
      if transit.length == 0
        @q[:TransitDistance] = ""
      else
        @q[:TransitDistance] = (@q[:location_C] - transit.collect{|d| d.to}.max().to_i)
      end

      @mainHash[i] = @q
    
    }
    
    print "\n"
    
    ###
    ### ICE LOGO and R Graphics for the peptides that were identified
    ###
    @foundPeptides = @mainHash.values.select{|x| x[:found]}

    # ICELOGO
    if @nterms # >1 because this is a 0 based count
      seqs = @foundPeptides.select{|e| e[:location_C]>1 and e[:ensembl].length == 0 and e[:tisdb].length == 0 and e[:isoforms].length == 0}
    else
      seqs = @foundPeptides.select{|e| e[:location_C] > e[:sequence].length  and e[:ensembl].length == 0 and e[:tisdb].length == 0 and e[:isoforms].length == 0}
    end
  
    begin
      IceLogo.new().terminusIcelogo(Species.find(1), seqs.collect{|e| e[:upstream]+":"+e[:downstream]}, "#{fileDir}/IceLogo.svg", 4) if seqs.length > 0
    rescue Exception => e
      print "Exception occured making Ice Logo " + e
    end
  
    # VENN DIAGRAM
    begin
      Venn.new(@foundPeptides).vennDiagram("#{fileDir}/VennDiagram")
    rescue Exception => e  
      print "Exception occured making Venn Diagram: " + e 
    end

	print "starting pathfinding\n"
    # PATHFINDING
    if(@proteaseWeb == "1")
      
      if(not Protein.find_by_ac(params[:pw_protease].strip).nil? and params[:pw_maxPathLength].to_i > 0)
   		if(params[:pw_maxPathLength].to_i > 4) 
   			params[:pw_maxPathLength] = "4"
   		end
        # @foundPeptides.each{|p| g.add_edge(params[:pw_protease], p[:acc], p[:location_C], "l")}
        finder = PathFinding.new(Graph.new(params[:pw_org],[]), params[:pw_maxPathLength].to_i, true, @nterminal, @cterminal, true)
        finder.find_all_paths(params[:pw_protease],  @foundPeptides.collect{|x|  {:id => x[:acc], :pos => x[:location_C]} })
		print " found paths at maxpathlength #{params[:pw_maxPathLength]}\n"
        finder.remove_direct_paths()
        @pw_paths = finder.get_paths()
        @pw_gnames = finder.paths_gene_names()  # GENE NAMES FOR PROTEINS FROM PATHS
		print " making graphviz\n"
        pdfPath = finder.make_graphviz(fileDir, @pw_gnames) # this saves the image but we need to define the path yet
		print " graphviz done\n"
      else
        p "protease not found" if Protein.find_by_ac(params[:pw_protease].strip).nil?
        p "pathlength invalid" if params[:pw_maxPathLength].to_i <= 0
        # TODO put error message on html??
      end
    end
	print "pathfinding done\n"    

    if(@proteaseStats == "1")
      if @foundPeptides.collect{|a| a[:proteases].length}.sum > 0 then
        es = EnrichmentStats.new(@foundPeptides, @foundPeptides[0][:protein].species_id) # TODO how to pick species?
        es.printStatsArrayToFile("#{fileDir}/ProteaseStats.txt")
        begin
          es.plotProteaseCounts("#{fileDir}/Protease_histogram")
        rescue Exception => e
          print "Exception occured making Protease Histogram: " + e
        end
        begin
          es.plotProteaseSubstrateHeatmap("#{fileDir}/ProteaseSubstrate_matrix")
        rescue Exception => e
          print "Exception occured making Protease Heatmap: " + e
        end
      end
    end


    ###
    ### Output data to Big table
    ###
    # #CSV TODO ctermini
    path = "#{fileDir}/Full_Table.txt"
    output = File.new(path, "w")
    output << "Accession\tInput Sequence\tProtein found\tRecommended Protein Name\tOther Names and IDs"
    output << "\tSpecies" if @spec
    output << "\tChromosome" if @chromosome
    # output << "\tChromosome band" if @cd chromosome # chromosome band information, removed, was shitty from BioMart
    output << "\tP10 to P1"
    output << "\tP1' to P10'"
    if @nterms
      output << "\tP1' Position"
    else
      output << "\tP1 Position"
    end
    output << "\tFull protein length (aa)"
    output << "\tExpected start (pos 1,2, or after signal-, pro-, or transit-peptide)\tUniProt curated start\tAlternative Spliced Start\tCleaving proteases\tOther experimental terminus evidences\tAlternative Translation Start" if @evidence
    output << "\tProtease Web Connections" if @proteaseWeb
    output << "\tN-terminal Features (Start to P1)\tFeatures spanning terminus (P1 to P1')\tC-terminal Features (P1' to End)" if @domain
    output << "\tDistance To signal peptide\tDistance to propeptide lost\tDistance to last transmembrane domain (shed)\tDistance to transit peptide (mitochondria)" if @domain and @nterms
    output << "\n"
  
    inprecisionRange = (-@nterminal..@cterminal).to_a
    
    @orderedInput.each{|x|
      q = @mainHash[x]
      if q[:found].nil?
        output << "#{q[:acc]}\t#{q[:full_pep]}\tno\n"
      elsif !q[:found]
        output << "#{q[:acc]}\t#{q[:full_pep]}\tno\n"
      else
        output << "#{q[:acc]}\t#{q[:full_pep]}\tYES"
        output << "\t#{q[:protein].recname}"
        output << "\t"
        output << "#{q[:protein].gn.name};" if !q[:protein].gn.nil?
        output << "#{q[:protein].proteinnames.collect{|pn| pn.full}.uniq.join(';')};#{q[:protein].merid}"
        output << "\t#{q[:species]}" if @spec
        output << "\t#{q[:chr][0]}" if @chromosome
        # output << "\t#{q[:chr][1]}" if @chromosome # chromosome band information, removed, was shitty from BioMart
        output << "\t#{q[:upstream]}"
        output << "\t#{q[:downstream]}"
        if @nterms
          output << "\t#{q[:location_C]+1}"
        else
          output << "\t#{q[:location_C]}"
        end
        output << "\t" + q[:protein].aalen.to_s
        if @evidence
          output << ((
            q[:location_C]+1 == 1 or 
            q[:location_C]+1 == 2 or 
            inprecisionRange.include?(q[:SigPDistance]) or  
            inprecisionRange.include?(q[:ProPDistance]) or 
            inprecisionRange.include?(q[:TransitDistance])
            ) ? "\tX" : "\t")
          output << (q[:uniprot].length > 0 ? "\tX" : "\t")
          # output << ((q[:isoforms].length > 0 or q[:ensembl].length > 0) ? "\tX" : "\t")
          output << (q[:ensembl].length > 0 ? "\tX" : "\t")
          output << ("\t" + q[:proteases].collect{|p| p.shortname}.uniq.join(';'))
          output << ("\t" + q[:otherEvidences].collect{|e| e.methodology}.uniq.join(";"))
          output << (q[:tisdb].length > 0 ? "\tX" : "\t")
        end

        if @proteaseWeb
          if @pw_paths.nil?
            output << "\t"
          else
            output << "\t" + @pw_paths[q[:acc] + "_"+ (q[:location_C]).to_s].collect{|path| 
              path.collect{|node|
                @pw_gnames[node[:id]].to_s
              }.join("->")
            }.join("; ")
          end
        end

        if @domain
          output << "\t" + q[:domains_before].collect{|d| "#{d.name} (#{d.description})"}.uniq.join(";")
          output << "\t" + q[:domains_at].collect{|d| "#{d.name} (#{d.description})"}.uniq.join(";")
          output << "\t" + q[:domains_after].collect{|d| "#{d.name} (#{d.description})"}.uniq.join(";")
          if @nterms
            output << "\t" + q[:SigPDistance].to_s
            output << "\t" + q[:ProPDistance].to_s
            output << "\t" + q[:ShedDistance].to_s
            output << "\t" + q[:TransitDistance].to_s
          end
        end
        output << "\n"
      end
    }
    output.close
    
    
    ###
    ### Zip and send by email
    ###
    x = system "cd #{dir}; zip -r #{label} #{label}"
  
    Emailer.new().sendTopFINDerResults(params[:email], "#{dir}/#{label}.zip", label)

    p "DONE"
  end
  
end