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
    @tpp = params['tpp']
    @mainarray = []
    @input1.each {|i|   
      @q = {}
      @q[:acc] = i.split("\s").fetch(0)
      @q[:pep] = i.split("\s").fetch(1).gsub(/[^[:upper:]]+/, "")
      @q[:full_pep] = i.split("\s").fetch(1)
      @q[:protein] = if Protein.find(:first, :conditions => ["ac = ?", @q[:acc]]) != nil
        Protein.find(:first, :conditions => ["ac = ?", @q[:acc]])
      else
      end
    
      @q[:chr] = if @chromosome 
        [@q[:protein].chromosome, @q[:protein].band] 
      end
    
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
      @q[:all_names] = Searchname.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]]).uniq      
      @q[:short_name] = Proteinname.find(:all, :conditions => ['protein_id = ? AND recommended = ?', @q[:sql_id], 1]).collect{|x| x.full}.uniq[0]     
      @q[:location] = if @tpp
        @q[:sequence].index(@q[:pep]) + 1
      else
        @q[:sequence].index(@q[:pep])
      end

      if not @q[:location].nil?
        @q[:location_1] = @q[:location] + 1
        @q[:location_range] = ((@q[:location] - @nterminal)..(@q[:location] + @cterminal)).to_a  
        @q[:upstream] = if @q[:location] < 10
          @q[:sequence][0, @q[:location]]
        else
          @q[:sequence][@q[:location] - 10, 10]
        end
      
        # NTERMINI AND EVIDENCES
        @q[:nterms] = Nterm.find(:all, :conditions => ["protein_id = ?", @q[:sql_id]]).select{|n| @q[:location_range].include? n.pos}
        @q[:evidences] =  @q[:nterms].collect {|b| Nterm2evidence.find(:all, :conditions => ['nterm_id = ?', b.id])}.flatten.collect{|n2e| n2e.evidence}
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
          @q[:cleavages] = @q[:cleavages].select{|c| @q[:location_range].include? c.pos}
          @q[:proteases] = @q[:cleavages].collect {|c| c.protease}
        else
          @q[:proteases] = []
        end
      
        # DOMAINS
        @q[:domains_all] = Ft.find(:all, :conditions => ['protein_id = ?', @q[:sql_id]])
        @q[:domains_all] = @q[:domains_all].select{|d| !["HELIX", "STRAND", "TURN", "CONFLICT", "VARIANT", "VAR_SEQ"].include? d.name} # FILTER OUT SOME UNINFORMATIVE ONES
        @q[:domains_before] = @q[:domains_all].select {|a| a.to.to_i < @q[:location_range].min}
        @q[:domains_at] = @q[:domains_all].select {|a| 
          (a.from.to_i <= @q[:location_range].min and a.to.to_i >= @q[:location_range].min)  || 
          (a.from.to_i <= @q[:location_range].max and a.to.to_i >= @q[:location_range].max)
        }
        @q[:domains_after] = @q[:domains_all].select {|a| a.from.to_i > @q[:location_range].max }
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

      else
        p "NOT PROCESSED: #{@q[:acc]} at #{@q[:pep]}" 
      end
    
      print "."
    }    
  

    # ICELOGO
    seqs = @mainarray.select{|e| e[:location]>2 and e[:ensembl].length == 0 and e[:tisdb].length == 0 and e[:isoforms].length == 0}
    IceLogo.new().terminusIcelogo(Species.find(1), seqs.collect{|e| e[:upstream]+":"+e[:pep]}, "#{fileDir}/IceLogo.svg", 4) if seqs.length > 0
    # IceLogo.new().terminusIcelogo(Species.find(1), @mainarray.select{|e| e[:proteases].collect{|p| p.ac}.include? "P33434"}.collect{|e| e[:upstream]+":"+e[:pep]}, "#{fileDir}/IceLogo_mmp2.svg", 4)
  
    # VENN DIAGRAM
    Venn.new(@mainarray).vennDiagram("#{fileDir}/VennDiagram")

    # PATHFINDING
    if(@proteaseWeb == "1")
      if(not Protein.find_by_ac(params[:pw_protease].strip).nil? and params[:pw_maxPathLength].to_i > 0)
        finder = PathFinding.new(Graph.new(params[:pw_org],[]), params[:pw_maxPathLength].to_i, true, @nterminal, @cterminal)
        @pw_paths = finder.find_all_paths(params[:pw_protease],  @mainarray.collect{|x|  {:id => x[:acc], :pos => x[:location]} })
        @pw_gnames = finder.paths_gene_names()  # GENE NAMES FOR PROTEINS FROM PATHS
        pdfPath = finder.make_graphviz(fileDir, @pw_gnames) # this saves the image but we need to define the path yet
      else
        p "protease not found" if Protein.find_by_ac(params[:pw_protease].strip).nil?
        p "pathlength invalid" if params[:pw_maxPathLength].to_i <= 0
        # TODO put error message on html??
      end

    end

    if @mainarray.collect{|a| a[:proteases].length}.sum > 0 then
      es = EnrichmentStats.new(@mainarray, @mainarray[0][:protein].species_id) # TODO how to pick species?
      es.printStatsArrayToFile("#{fileDir}/ProteaseStats.tsv")
      es.plotProteaseCounts("#{fileDir}/Protease_histogram")
      es.plotProteaseSubstrateHeatmap("#{fileDir}/ProteaseSubstrate_matrix")
    end


    # #CSV
    path = "#{fileDir}/Full_Table.tsv"
    output = File.new(path, "w")
    output << "Accession\tInput Sequence\tRecommended Protein Name\tOther Names and IDs\t" +
    if @spec; "Species" end +
    if @chromosome; "\tChromosome & Band\t" end +
    "P10 to P10′\tP1′ Position" +
    if @evidence; "\tUniProt annotated start\tIsoform Start\tAlternative Spliced Start\tCleavingProteases\tOther terminus evidences\tAlternative Translation Start" end +
    if @proteaseWeb; "\tProtease Web Connections" end +
    if @domain; "\tN-terminal Features (Start to P1)\tFeatures At Position (P1')\tC-terminal Features (P2' to End)\tSignalpeptide lost\tPropeptide lost\tShed" end +
    "\n"
  
  
    @mainarray.each{|q|
      output << "#{q[:acc]}\t#{q[:full_pep]}\t#{q[:short_name]}\t#{q[:all_names].collect{|s| s.name}.uniq.join(';')}" +
      if @spec; "\t#{q[:species]}" end +
      if @chromosome; "\t#{q[:chr].join('')}" end +
      "\t#{q[:upstream]} | #{q[:pep]}\t#{q[:location_1]}"
      if @evidence
        output << (q[:uniprot].length > 0 ? "\tX" : "\t")
        output << (q[:isoforms].length > 0 ? "\tX" : "\t") 
        output << (q[:ensembl].length > 0 ? "\tX" : "\t")
        output << ("\t" + q[:proteases].collect{|p| p.shortname}.join(';'))
        output << ("\t" + q[:otherEvidences].collect{|e| e.methodology}.uniq.join(";"))
        output << (q[:tisdb].length > 0 ? "\tX" : "\t")
      end

      if @proteaseWeb
        output << "\t" + @pw_paths[q[:acc] + "_"+ q[:location].to_s].collect{|path| 
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
    }
    output.close

    x = system "cd #{dir}; zip -r TopFINDer_results TopFINDer_results"
  
    Emailer.new().sendTopFINDer(params[:email], "#{dir}/TopFINDer_results.zip")

    p "DONE"
  end
  
end