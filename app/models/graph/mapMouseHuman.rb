# 

class MapMouseHuman
  
  def initialize()
    @map = []
    File.open("databases/one2one_large.csv").readlines.each do |line|
       l = line.split(";")
       @map << {:h => l[1].strip(), :m => l[0].strip()}
    end
  end
  
  def mouse4human(proteins)
    return proteins.collect{|p| m4h(p)}
  end
  
  def human4mouse(proteins)
    return proteins.collect{|p| h4m(p)}
  end
  
  
  def m4h(prot)
    x =  @map.find{|hash| hash[:h] == prot}
    return x.nil? ? "No mouse AC found" : x[:m]
  end
  
  def h4m(prot)
    x =  @map.find{|hash| hash[:m] == prot}
    return x.nil? ? "No human AC found" : x[:h]
  end
  
end