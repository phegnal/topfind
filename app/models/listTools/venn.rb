class Venn
  
  def initialize(mainarray)
    require 'rserve'    
    @@mainarray=mainarray
    @@r = Rserve::Connection.new
  end
  
  def vennDiagram(path)
    @@r.void_eval("x = list()")
    @@mainarray.each_with_index{|x, i|
      # @@r.assign("v", [x[:uniprot].length > 0, (x[:isoforms].length > 0 or x[:ensembl].length > 0), x[:tisdb].length > 0, x[:proteases].length > 0,  x[:otherEvidences].length > 0])
      @@r.assign("v", [x[:uniprot].length > 0, x[:ensembl].length > 0, x[:tisdb].length > 0, x[:proteases].length > 0,  x[:otherEvidences].length > 0])
      @@r.void_eval("x[[#{i+1}]]=v")
    }
    @@r.void_eval("y = data.frame(do.call(rbind, x))")
    @@r.void_eval("colnames(y) = c('Curated\nStart', 'Alternatively\nSpliced', 'Alternatively\nTranslated', 'Cleaved', 'Experimentally\nObserved')")
    @@r.void_eval("library(gplots)")
    @@r.void_eval("svg('#{path}.svg')")
    @@r.void_eval("venn(y)")
    @@r.void_eval('dev.off()')
  end
end
  