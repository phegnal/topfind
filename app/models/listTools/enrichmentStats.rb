class EnrichmentStats
  
  
  def initialize(mainarray, organism)
    
    require "rubystats"
    require 'rserve'
    
    @@mainarray=mainarray
    # REMOVED - users need to use one line per peptide
    # @@uniquePeptideArray = mainarray.collect{|x| x[:pep]}.uniq.collect{|p|
    #   {
    #
    #     :pep => p,
    #     :proteases => mainarray.select{|x| x[:pep] == p}.collect{|x| x[:proteases]}.flatten.uniq
    #   }
    # }
    @@statsArray = []
    @@r = Rserve::Connection.new
   
    if not mainarray.nil?
      proteases = @@mainarray.collect{|h| h[:proteases].uniq}.flatten

      # g_query = "select count(distinct c.substrate_id, c.pos) from cleavages c, proteins p, proteins s where c.protease_id = p.id and c.substrate_id = s.id and p.species_id = #{organism} and s.species_id = #{organism};"
      substrateIDs = @@mainarray.collect{|p| p[:protein].id}
      proteaseIDs = proteases.collect{|p| p.id}
      g_query = "select count(distinct c.substrate_id, c.pos) 
      from cleavages c, proteins p, proteins s, cleavage2evidences c2e, evidence2evidencecodes e2code, evidencecodes code
      where c.protease_id = p.id 
      and c.substrate_id = s.id 
      and s.id in (#{substrateIDs.join(",")})
      and p.id in (#{proteaseIDs.join(",")})
      and c.id = c2e.cleavage_id
      and c2e.evidence_id = e2code.evidence_id
      and code.id = e2code.code
      and code.code not in ('TopFIND:0000001', 'TopFIND:0000002');"
      @@dbCleavageTotal = nil
      ActiveRecord::Base.connection.execute(g_query).each{|y| @@dbCleavageTotal = y[0].to_i};
      @@listCleavageTotal = @@mainarray.select{|h| h[:proteases].length > 0}.length

      proteases.uniq.each{|p|
        listCleavageProtease = proteases.count(p)
        dbCleavageProtease = p.cleavages.select{|c| !c.substrate.nil?}.select{|c| substrateIDs.include? c.substrate.id}.select{|c|
          c.evidences.collect{|e| e.evidencecodes.collect{|c| c.code}}.flatten.uniq.select{|c| !["TopFIND:0000001", "TopFIND:0000002"].include? c}.length > 0
        }.collect{|c| "#{c.substrate.name}_#{c.pos}"}.uniq.length
        fet = FishersExactTest.new().calculate(listCleavageProtease, dbCleavageProtease, @@listCleavageTotal - listCleavageProtease, @@dbCleavageTotal - dbCleavageProtease)
        @@statsArray << {
          :protein => p,
          :listCount => listCleavageProtease, 
          :dbCount => dbCleavageProtease,
          :listFraction => listCleavageProtease.to_f/@@listCleavageTotal.to_f,
          :dbFraction => dbCleavageProtease.to_f/@@dbCleavageTotal.to_f,
          :fet => fet[:right]
        }
      }
      @@r.assign("ps", @@statsArray.collect{|x| x[:fet]})
      fetAdj = @@r.eval("p.adjust(ps, method = 'BH')").to_ruby
      fetAdj = [fetAdj] if fetAdj.class == Float
      fetAdj.each_with_index{|x, i|  @@statsArray[i][:fetAdj] = x }
    end
  end
  
  def printStatsArrayToFile(path)
    output = File.new(path, "w")
    output << ["Protease name", "Protease accession", "List count (total = #{@@listCleavageTotal})", "DB count (total = #{@@dbCleavageTotal})", "Fold enrichment", "Fold coverage", "Fisher Exact Test", "Adjusted Fisher Exact Test"].join("\t")
    output << "\n"
    @@statsArray.each{|x|
      output << x[:protein].shortname + "\t"
      output << x[:protein].ac + "\t"
      output << x[:listCount].to_s + "\t"
      output << x[:dbCount].to_s + "\t"
      output << (x[:listFraction]/x[:dbFraction]).to_s + "\t"
      output << (x[:listCount].to_f/x[:dbCount].to_f).to_s + "\t"
      output << x[:fet].to_s + "\t"
      output << x[:fetAdj].to_s
      output << "\n"
    }
    output.close
  end
  
  def printAllStatsArrayToFile(path)
    output = File.new(path, "w")
    fields = @@statsArray[1].keys
    output << fields.join("\t")
    output << "\t\n"
    @@statsArray.each{|x|
      fields.each{|f|
        output << x[f].to_s+"\t"
      }
      output << "\n"
    }
    output.close
  end
  
  def getStatsArray
    return @@statsArray
  end
  
  def plotProteaseSubstrateHeatmap(path)
    proteases = @@statsArray.collect{|x| x[:protein].shortname}
    matrix = []
    # in matrix each element is an array of true/false or 1/0 later in the order of the proteases
    @@mainarray.each{|s| matrix << proteases.collect{|p| s[:proteases].flatten.collect{|x| x.shortname}.include? p }}
    matrix = matrix.collect{|a| a.collect{|x| if(x) then 1 else 0 end }}
    keepRows = (0..(matrix.length-1)).to_a.select{|row| matrix[row].sum > 0}
    matrix2 = []
    rownames = []
    keepRows.each{|i|
      matrix2 << matrix[i]
      rownames << @@mainarray[i][:protein].shortname+"_"+@@mainarray[i][:location_C].to_s
    }
    plotHeatmap(path, matrix2, proteases, rownames)
  end

  def testHeatmap()
    plotHeatmap("~/Desktop/x.pdf", [[0,0,0,0],[1,1,1,1]], ["X", "Y"] ,["a", "b", "c", "d"])
  end
  
  # matrix is an array of arrays with all the same length
  def plotHeatmap(path, matrix, proteaseNames, substrateNames)
    @@r.assign("psMat", matrix)
    @@r.assign("proteaseNames", proteaseNames)
    @@r.assign("substrateNames", substrateNames)
    @@r.void_eval("m <- do.call(rbind, psMat)")
    @@r.void_eval("colnames(m) <- proteaseNames")
    @@r.void_eval("rownames(m) <- substrateNames")
    @@r.void_eval('m=m[hclust(dist(m))$order, ]')
    @@r.void_eval('m=m[,hclust(dist(t(m)))$order]')
    @@r.void_eval("library(ggplot2)")
    @@r.void_eval("library(reshape2)")
    @@r.void_eval('df = melt(m)')
    @@r.void_eval('colnames(df) = c("Terminus", "Protease", "Cleavage")')
    @@r.void_eval('df$Cleavage[df$Cleavage == 1] <- "Cleaved"')
    @@r.void_eval('df$Cleavage[df$Cleavage == "0"] <- "Not Cleaved"')
    @@r.void_eval('df$Cleavage = factor(df$Cleavage)')
    @@r.void_eval('p <- ggplot(data=df, aes(x=Protease, y=Terminus))')
    @@r.void_eval('p <- p + geom_tile(aes(fill = Cleavage))')
    @@r.void_eval('p <- p + scale_fill_manual(values = c("red", "black"))')
    @@r.void_eval('p <- p + theme_bw()')
    @@r.void_eval('p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1))')
    @@r.void_eval("ggsave('#{path}.svg', width = 3+ length(proteaseNames)/7, height = 3+ length(substrateNames)/7, limitsize = F, plot = p)")
  end
  
  # def plotHeatmap(path, matrix, proteaseNames, substrateNames)
  #   @@r.assign("psMat", matrix)
  #   @@r.assign("proteaseNames", proteaseNames)
  #   @@r.assign("substrateNames", substrateNames)
  #   @@r.void_eval("psMat <- do.call(rbind, psMat)")
  #   @@r.void_eval("colnames(psMat) <- proteaseNames")
  #   @@r.void_eval("rownames(psMat) <- substrateNames")
  #   @@r.void_eval("svg('#{path}.svg', height = 20, width = 20)")
  #   # , width = min(c((3 + length(proteaseNames))/7, 20)), height = min(c((3 + length(substrateNames))/7, 20)))")
  #   # p @@r.eval("psMat")
  #   @@r.void_eval("heatmap(psMat, scale = 'none', col=c('black', 'red'))")
  #   @@r.void_eval('dev.off()')
  # end
  
  def plotProteaseCounts(path)
    @@r.assign("counts", @@statsArray.collect{|x| x[:listCount]})
    @@r.assign("countsNam", @@statsArray.collect{|x| x[:protein].shortname})
    @@r.assign("sig", @@statsArray.collect{|x| x[:fetAdj] < 0.05})
    @@r.void_eval("significant = sig")
    @@r.void_eval('significant[sig] = "q < 0.05"')
    @@r.void_eval('significant[!sig] = "q > 0.05"')    
    @@r.void_eval('significant <- factor(significant, levels = c("q > 0.05", "q < 0.05"))')    
    @@r.void_eval("df <- data.frame(Protease = factor(countsNam, levels = countsNam[order(counts, decreasing = T)]), Cleavages = counts, Significant = significant)")
    @@r.void_eval('palette <- c("black", "red")')
    @@r.void_eval("library(ggplot2)")
    @@r.void_eval('p <- ggplot(data = df, aes(y = Cleavages, x = Protease, fill = Significant)) + geom_bar(stat="identity") + theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +  scale_fill_manual(values=palette)')
    @@r.void_eval("ggsave(paste0('#{path}','.svg'), width = 3+ length(counts)/7, limitsize = F, plot = p)")
    @@r.void_eval("dev.off()")
  end
    
  # def plotProteaseCounts2(path)
  #   @@r.assign("counts", @@statsArray.collect{|x| x[:listCount]})
  #   @@r.assign("countsNam", @@statsArray.collect{|x| x[:protein].shortname})
  #   @@r.void_eval("names(counts) <- countsNam")
  #   @@r.void_eval("svg('#{path}.svg')")
  #   @@r.void_eval("barplot(sort(counts, decreasing = T), las = 2, col = 'blue', ylab = 'Cleavages in the list')")
  #   @@r.void_eval('dev.off()')
  # end

  
end