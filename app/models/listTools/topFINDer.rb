class TopFINDer
  def initialize()    
  end
  
  def analyze(params)
    
    require 'graph/pathFinding'
    require 'graph/graph'
    require 'listTools/enrichmentStats'
    require 'listTools/iceLogo'
    require 'listTools/venn'
    require 'listTools/emailer'
    
    nr = Dir.entries("#{RAILS_ROOT}/public/explorer").collect{|x| x.to_i}.max + 1
    dir = "#{RAILS_ROOT}/public/explorer/" + nr.to_s 
    Dir.mkdir(dir)
    fileDir = dir + "/TopFINDer_results"
    Dir.mkdir(fileDir)
  
    @all_input = params["all"].strip #string
    @input1 = @all_input.split("\n") #array 
    @chromosome = params['chromosome']
    @domain = params['domain']
    @evidence = params['evidence']
    @proteaseWeb = params[:proteaseWeb]
    @spec = params['spec']
    @nterminal = params['nterminal'].to_i
    @cterminal = params['cterminal'].to_i
    @mainarray = []
    @nterms = true
    @input1.each {|i|  
      print "." 
      @q = {}

      @q[:acc] = i.split("\s").fetch(0)
      #@q[:pep] = i.split("\s").fetch(1).gsub(/[^[:upper:]]+/, "")
      @q[:pep] = i.split("\s").fetch(1).gsub(/^.{1}\./,"").gsub(/\..{1}$/,"").gsub(/[^[:upper:]]+/, "")
      @q[:full_pep] = i.split("\s").fetch(1)
      @q[:protein] = if Protein.find(:first, :conditions => ["ac = ?", @q[:acc]]) != nil
        Protein.find(:first, :conditions => ["ac = ?", @q[:acc]])
      else
      end
      
      # get location if protein is found
      if not @q[:protein].present?
        @q[:found] = false
        @mainarray << @q
        next
      else
        @q[:sequence] = @q[:protein].sequence
        if @nterms
          @q[:location_C] = @q[:sequence].index(@q[:pep])
        else # TODO c-termini will fail I think
          @q[:location_C] = @q[:sequence].index(@q[:pep]) + @q[:pep].length
        end
      end

      # is location found otherwise don't process
      if @q[:location_C].nil?
        @q[:found] = false
        @mainarray << @q
        next
      end

      if @q[:protein].present? and @q[:location_C] >= 0
        @q[:found] = true
      end

      @q[:location_C_range] = ((@q[:location_C] - @nterminal)..(@q[:location_C] + @cterminal)).to_a  
      @q[:location_N_range] = @q[:location_C_range].collect{|x| x + 1}
      if @nterms
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
      else
        if @q[:location_C] + 10 > @q[:sequence].length
          @q[:downstream] =  @q[:sequence][@q[:location_C] + 1, @q[:sequence].length-@q[:location_C]]
        else
          @q[:downstream] =  @q[:sequence][@q[:location_C] + 1, 10]
        end
      end
          
      @q[:chr] = if @chromosome 
        [@q[:protein].chromosome, @q[:protein].band] 
      end
    
      @q[:species] = @q[:protein].species.common_name
      
      @q[:sql_id] = @q[:protein].id
      @q[:all_names] = Searchname.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]]).uniq      
      
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
        elsif  e.evidencesource.dbname == "TopFIND"
          @q[:isoforms] << e
        else
        end
      }
            
      # CLEAVAGES
      @q[:cleavages] = Cleavage.find(:all, :conditions => ["substrate_id = ?", @q[:sql_id]])
      if not @q[:cleavages].nil?
        @q[:cleavages] = @q[:cleavages].select{|c| @q[:location_C_range].include? c.pos + 1}
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
        
      if @q[:domains_all].collect{|d| d.name}.include? "SIGNAL"
        @q[:SignalLost] = !(@q[:domains_after].collect{|d| d.name}.include? "SIGNAL")
      end
      if @q[:domains_all].collect{|d| d.name}.include? "PROPEP"
        @q[:ProPeptideLost] = !(@q[:domains_after].collect{|d| d.name}.include? "PROPEP")
      end
      if @q[:domains_all].collect{|d| d.name}.include? "TRANSMEM"
        @q[:shed] = !(@q[:domains_after].collect{|d| d.name}.include? "TRANSMEM")
      end

      @mainarray << @q
    
    }    
    
    print "\n"
  
    @foundPeptides = @mainarray.select{|x| x[:found]}

    # ICELOGO TODO ctermini
    if @nterms
      seqs = @foundPeptides.select{|e| e[:location_C]>1 and e[:ensembl].length == 0 and e[:tisdb].length == 0 and e[:isoforms].length == 0}
      IceLogo.new().terminusIcelogo(Species.find(1), seqs.collect{|e| e[:upstream]+":"+e[:pep]}, "#{fileDir}/IceLogo.svg", 4) if seqs.length > 0
    else
      seqs = @foundPeptides.select{|e| e[:location_C] < 0  and e[:ensembl].length == 0 and e[:tisdb].length == 0 and e[:isoforms].length == 0}
      IceLogo.new().terminusIcelogo(Species.find(1), seqs.collect{|e| e[:upstream]+":"+e[:pep]}, "#{fileDir}/IceLogo.svg", 4) if seqs.length > 0
    end
  
    # VENN DIAGRAM
    begin
      Venn.new(@foundPeptides).vennDiagram("#{fileDir}/VennDiagram")
    rescue Exception => e  
      print "Exception occured making Venn Diagram: " + e 
    end

    # PATHFINDING TODO Ctermini
    if(@proteaseWeb == "1")
      if(not Protein.find_by_ac(params[:pw_protease].strip).nil? and params[:pw_maxPathLength].to_i > 0)
        finder = PathFinding.new(Graph.new(params[:pw_org],[]), params[:pw_maxPathLength].to_i, true, @nterminal, @cterminal)
        @pw_paths = finder.find_all_paths(params[:pw_protease],  @foundPeptides.collect{|x|  {:id => x[:acc], :pos => x[:location_C]} })
        @pw_gnames = finder.paths_gene_names()  # GENE NAMES FOR PROTEINS FROM PATHS
        pdfPath = finder.make_graphviz(fileDir, @pw_gnames) # this saves the image but we need to define the path yet
      else
        p "protease not found" if Protein.find_by_ac(params[:pw_protease].strip).nil?
        p "pathlength invalid" if params[:pw_maxPathLength].to_i <= 0
        # TODO put error message on html??
      end

    end

    if @foundPeptides.collect{|a| a[:proteases].length}.sum > 0 then
      es = EnrichmentStats.new(@foundPeptides, @foundPeptides[0][:protein].species_id) # TODO how to pick species?
      es.printStatsArrayToFile("#{fileDir}/ProteaseStats.tsv")
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


    # #CSV TODO ctermini
    path = "#{fileDir}/Full_Table.tsv"
    output = File.new(path, "w")
    output << "Accession\tInput Sequence\tRecommended Protein Name\tOther Names and IDs"
    output << "\tSpecies" if @spec
    output << "\tChromosome band" if @chromosome
    output << "\tP10 to P10'" + "\tP1' Position"
    output << "\tUniProt annotated start\tIsoform Start\tAlternative Spliced Start\tCleavingProteases\tOther terminus evidences\tAlternative Translation Start" if @evidence
    output << "\tProtease Web Connections" if @proteaseWeb
    output << "\tN-terminal Features (Start to P1)\tFeatures At Position (P1')\tC-terminal Features (P2' to End)\tSignalpeptide lost\tPropeptide lost\tShed" if @domain
    output << "\n"
  
  
    @mainarray.each{|q|
      if !q[:found]
        output << "#{q[:acc]}\t#{q[:full_pep]}\n"
      else
        output << "#{q[:acc]}\t#{q[:full_pep]}\t#{q[:protein].recname}\t#{q[:all_names].collect{|s| s.name}.uniq.join(';')}"
        output << "\t#{q[:species]}" if @spec
        output << "\t#{q[:chr].join('')}" if @chromosome
        output << "\t#{q[:upstream]} | #{q[:downstream]}\t#{q[:location_C]+1}"
        if @evidence
          output << (q[:uniprot].length > 0 ? "\tX" : "\t")
          output << (q[:isoforms].length > 0 ? "\tX" : "\t") 
          output << (q[:ensembl].length > 0 ? "\tX" : "\t")
          output << ("\t" + q[:proteases].collect{|p| p.shortname}.join(';'))
          output << ("\t" + q[:otherEvidences].collect{|e| e.methodology}.uniq.join(";"))
          output << (q[:tisdb].length > 0 ? "\tX" : "\t")
        end

        if @proteaseWeb
          output << "\t" + @pw_paths[q[:acc] + "_"+ (q[:location_C]).to_s].collect{|path| 
            path.collect{|node|
              @pw_gnames[node[:id]].to_s
            }.join("->")		
          }.join("; ")
        end

        if @domain
          output << "\t" + q[:domains_before].collect{|d| "#{d.name} (#{d.description})"}.uniq.join(";")
          output << "\t" + q[:domains_at].collect{|d| "#{d.name} (#{d.description})"}.uniq.join(";")
          output << "\t" + q[:domains_after].collect{|d| "#{d.name} (#{d.description})"}.uniq.join(";")
          output << "\t"
          output << "X" if !q[:SignalLost].nil? & q[:SignalLost]
          output << "\t"
          output << "X" if !q[:ProPeptideLost].nil? & q[:ProPeptideLost]
          output << "\t"
          output << "X" if !q[:shed].nil? & q[:shed]
        end
        output << "\n"
      end
    }
    output.close

    x = system "cd #{dir}; zip -r TopFINDer_results TopFINDer_results"
  
    Emailer.new().sendTopFINDer(params[:email], "#{dir}/TopFINDer_results.zip")

    p "DONE"
  end
  
end