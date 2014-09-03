class Venn
  
  def initialize(mainarray)
    require 'rserve'    
    @@mainarray=mainarray
    @@r = Rserve::Connection.new
  end
  
  def vennDiagram(path)
    @@r.void_eval("x = list()")
    @@mainarray.each_with_index{|x, i|
      @@r.assign("v", [x[:uniprot?], x[:isoforms], x[:proteases].length > 0, x[:ensembl?]])
      @@r.void_eval("x[[#{i+1}]]=v")
    }
    @@r.void_eval("y = data.frame(do.call(rbind, x))")
    @@r.void_eval("colnames(y) = c('Canonical', 'Isoform', 'Cleaved', 'Spliced')")
    @@r.void_eval("library(gplots)")
    @@r.void_eval("pdf('#{path}')")
    @@r.void_eval("venn(y)")
    @@r.void_eval('dev.off()')
  end

end
  