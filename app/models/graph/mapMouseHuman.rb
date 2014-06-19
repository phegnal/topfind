# 

class MapMouseHuman
  
  def initialize()
    @map = []
    File.open("/Users/Nik/Desktop/PhD/dry_lab/R/Network_Files/merged/one2one_large.csv").readlines.each do |line|
       l = line.split(";")
       @map << {"h" => l[1].strip(), "m" => l[0].strip()}
    end
  end
  
  def mouse4human(proteins)
    @map.select{|x| proteins.include?(x["h"])}
  end
  
  def human4mouse(proteins)
    @map.select{|x| proteins.include?(x["m"])}
  end
  
end