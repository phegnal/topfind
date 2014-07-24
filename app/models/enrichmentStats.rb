class EnrichmentStats
  
  def initialize(mainarray)
    
    require "rubystats"
    require 'rserve'
    
    @@mainarray=mainarray
    @@statsArray = []
    @@r = Rserve::Connection.new
   
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
  
  
  def plotProteaseCounts(path)
    @@r.assign("counts", @@statsArray.collect{|x| x[:list]})
    @@r.assign("countsNam", @@statsArray.collect{|x| x[:p].name})
    @@r.void_eval("names(counts) <- countsNam")
    @@r.void_eval("pdf('#{path}')")
    @@r.void_eval("barplot(sort(counts, decreasing = T), las = 2, col = 'blue', ylab = 'Cleavages in the list')")
    @@r.void_eval('dev.off()')
  end
  
  def getStatsArray
    return @@statsArray
  end
  
end