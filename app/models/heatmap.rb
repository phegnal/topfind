class Heatmap

  attr_accessor :cleavagesites, :colors, :as, :positions

  def initialize(cleavagesites,
      colors = ["#00007F", "#0000B2", "#0000E5", "#0019FF", "#004CFF", "#007FFF", "#00B2FF", "#00E5FF", "#19FFE5", "#4CFFB2", "#7FFF7F", "#B2FF4C", "#E5FF19", "#FFE500",
 "#FFB200", "#FF7F00", "#FF4C00", "#FF1900", "#E50000", "#B20000", "#7F0000"],
      as = ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y'],
      positions= ["p5","p4","p3","p2","p1","p1'","p2'","p3'","p4'","p5'"])
      
    @cleavagesites = cleavagesites
    @colors = colors
    @positions = positions
    @as = as
  end
   
  def matrix   
    n = self.positions.count  
    self.cleavagesites.each_with_index do |c,i| 
      if i == 0
        @matrix = c.cleavagesitematrix(n/2,n/2)
      else
        @matrix = @matrix + c.cleavagesitematrix(n/2,n/2)
      end
    end
    #build percentages
    total = 0
    @matrix.map { |x| total = total+x}
    total = total/10
    # percentmatrix = @matrix.map {|x| x/total*100} 
    
    rowarray = Array.new
    positions.each_with_index do |p,i|
      #get the total number of amainoacids reported at the given position
      postotal = cleavagesites.*.p1.compact.count
      postotal == 0 ? postotal = 1 : postotal 
      r =  @matrix.row(i)
      rowarray << r.map {|x| x/postotal*100}
    end
    
    percentmatrix = Matrix.rows(rowarray)
    
    #normalize to natural abundance
    naturalarray = []
    10.times { naturalarray << [6.99,2.23,4.89,7.03,3.68,6.52,2.56,4.32,5.65,10.04,2.17,3.57,6.18,4.74,5.63,8.39,5.35,6.13,1.22,2.70]}
    natural = Matrix.rows(naturalarray)
    
    norm = percentmatrix - natural
    
    matrix = percentmatrix
    
    arraymatrix = matrix.transpose.to_a    
    
    return arraymatrix 
  end  

  def color(v)
    bin = (v.round)/5
    return self.colors[bin]
  end
  
  def colorvalue(color)
    bin = self.colors.index(color)
    bin*5
  end
  

  
end