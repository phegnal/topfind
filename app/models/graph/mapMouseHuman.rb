# 

class MapMouseHuman
  
  def initialize()
    @map = []
    File.open("databases/paranoid8_many2many.txt").readlines.each do |line|
       l = line.split("\t")
       @map << {:h => l[0].strip(), :m => l[1].strip()}
    end
  end
  
  def mouse4human(proteins)
    return proteins.collect{|p| m4h(p)}.flatten
  end
  
  def human4mouse(proteins)
    return proteins.collect{|p| h4m(p)}.flatten
  end
  
  
  def m4h(prot)
    return  @map.find_all{|hash| hash[:h] == prot}.collect{|x| x[:m]}
  end
  
  def h4m(prot)
    return  @map.find_all{|hash| hash[:m] == prot}.collect{|x| x[:h]}
  end
  
end