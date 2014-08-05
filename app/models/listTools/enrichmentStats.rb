class EnrichmentStats
  
  
  def initialize(mainarray)
    
    require "rubystats"
    require 'rserve'
    
    @@mainarray=mainarray
    @@statsArray = []
    @@r = Rserve::Connection.new
   
    if not mainarray.nil?
      listCleavages = @@mainarray.collect{|h| h[:proteases]}.flatten

      g_query = "select count(c.id) from cleavages c, proteins p where c.protease_id = p.id and p.species_id = 1;"
      dbCleavageTotal = 0
      ActiveRecord::Base.connection.execute(g_query).each{|y| dbCleavageTotal = y[0].to_i};
      listCleavageTotal = listCleavages.length

      listCleavages.uniq.each{|p|
        listCleavageProtease = listCleavages.count(p)
        dbCleavageProtease = p.cleavages.length 
        fet = FishersExactTest.new().calculate(listCleavageProtease, dbCleavageProtease, listCleavageTotal - listCleavageProtease, dbCleavageTotal - dbCleavageProtease)
        @@statsArray << {
          :p => p,
          :list => listCleavageProtease, 
          :listPercent => listCleavageProtease.to_f/listCleavageTotal.to_f,
          :dbPercent => dbCleavageProtease.to_f/dbCleavageTotal.to_f,
          :fet => fet[:right]
        }
      }
      @@r.assign("ps", @@statsArray.collect{|x| x[:fet]})
      @@r.eval("p.adjust(ps, method = 'BH')").to_ruby.each_with_index{|x, i|
        @@statsArray[i][:fetAdj] = x
      }
    end
  end
  
  
  def getStatsArray
    return @@statsArray
  end
  
  def plotProteaseSubstrateHeatmap(path)
    proteases = @@statsArray.collect{|x| x[:p].name}
    matrix = []
    @@mainarray.each{|s| matrix << proteases.collect{|p| s[:proteases].flatten.collect{|x| x.name}.include? p }}
    matrix = matrix.collect{|a| a.collect{|x| if(x) then 1 else 0 end }}
    plotHeatmap(path, matrix, proteases, @@mainarray.collect{|p| p[:protein].name})
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
    @@r.assign("counts", @@statsArray.collect{|x| x[:list]})
    @@r.assign("countsNam", @@statsArray.collect{|x| x[:p].name})
    @@r.void_eval("names(counts) <- countsNam")
    @@r.void_eval("pdf('#{path}')")
    @@r.void_eval("barplot(sort(counts, decreasing = T), las = 2, col = 'blue', ylab = 'Cleavages in the list')")
    @@r.void_eval('dev.off()')
  end

  
end