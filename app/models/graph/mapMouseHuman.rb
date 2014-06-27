# 

class MapMouseHuman
  
  def initialize()
    @map = []
    File.open("databases/one2one_large.csv").readlines.each do |line|
       l = line.split(";")
       @map << {"h" => l[1].strip(), "m" => l[0].strip()}
    end
  end
  
  def mouse4human(proteins)
    # if there is only one protein
    if proteins.class == String then
      proteins = [proteins]
    end
    return @map.select{|x| proteins.include?(x["h"])}.collect{|x| x["m"]}
  end
  
  def human4mouse(proteins)
    # if there is only one protein
    if proteins.class == String then
      proteins = [proteins]
    end
    return @map.select{|x| proteins.include?(x["m"])}.collect{|x| x["h"]}
  end
  
end