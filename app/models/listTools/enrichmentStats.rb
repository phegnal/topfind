class EnrichmentStats
  
  
  def initialize(mainarray, organism)
    
    require "rubystats"
    require 'rserve'
    
    @@mainarray=mainarray
    @@statsArray = []
    @@r = Rserve::Connection.new
   
    if not mainarray.nil?
      proteases = @@mainarray.collect{|h| h[:proteases].uniq}.flatten

      g_query = "select count(distinct c.substrate_id, c.pos) from cleavages c, proteins p, proteins s where c.protease_id = p.id and c.substrate_id = s.id and p.species_id = #{organism} and s.species_id = #{organism};"
      @@dbCleavageTotal = nil
      ActiveRecord::Base.connection.execute(g_query).each{|y| @@dbCleavageTotal = y[0].to_i};
      @@listCleavageTotal = @@mainarray.select{|h| h[:proteases].length > 0}.length

      proteases.uniq.each{|p|
        listCleavageProtease = proteases.count(p)
        dbCleavageProtease = p.cleavages.select{|c| !c.substrate.nil?}.collect{|c| "#{c.substrate.name}_#{c.pos}"}.uniq.length 
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
      @@r.eval("p.adjust(ps, method = 'BH')").to_ruby.each_with_index{|x, i|
        @@statsArray[i][:fetAdj] = x
      }
    end
  end
  
  def printStatsArrayToFile(path)
    output = File.new(path, "w")
    output << ["protease name", "protease accession", "list count (total = #{@@listCleavageTotal})", "db count (total = #{@@dbCleavageTotal})", "fold enrichment", "fold coverage", "Fisher Exact Test", "Adjusted Fisher Exact Test"].join("\t")
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
      rownames << @@mainarray[i][:protein].shortname+"_"+@@mainarray[i][:location_1].to_s
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
    @@r.void_eval("psMat <- do.call(rbind, psMat)")
    @@r.void_eval("colnames(psMat) <- proteaseNames")
    @@r.void_eval("rownames(psMat) <- substrateNames")
    @@r.void_eval("pdf('#{path}')")
    @@r.void_eval("heatmap(psMat, scale = 'none', col=c('black', 'red'))")
    @@r.void_eval('dev.off()')
  end
  
  
  def plotProteaseCounts(path)
    @@r.assign("counts", @@statsArray.collect{|x| x[:listCount]})
    @@r.assign("countsNam", @@statsArray.collect{|x| x[:protein].shortname})
    @@r.void_eval("names(counts) <- countsNam")
    @@r.void_eval("pdf('#{path}')")
    @@r.void_eval("barplot(sort(counts, decreasing = T), las = 2, col = 'blue', ylab = 'Cleavages in the list')")
    @@r.void_eval('dev.off()')
  end

  
end