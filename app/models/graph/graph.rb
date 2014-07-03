class Graph
      
  def initialize(species)
    @g = {}
    if(species == "human") 
      @species_id = 1
    else 
      @species_id = 2 
    end
    graph_from_sql()
  end
    
  def graph_array()
    return @g
  end
  
  def graph_from_sql()     
    c_query = "SELECT p.ac as protease, s.ac, c.pos as substrate from cleavages c, proteins p, proteins s WHERE p.id = c.protease_id AND s.id = c.substrate_id AND p.species_id = #{@species_id} AND s.species_id = #{@species_id};"
    c_result =  ActiveRecord::Base.connection.execute(c_query);
    c_result.each{|x| 
      add_edge(x[0], x[1], x[2].to_i)
      }
    
    i_query = "SELECT i.ac as inhibitor, p.ac as protease from inhibitions inh, proteins i, proteins p WHERE i.id = inh.inhibitor_id AND p.id = inh.inhibited_protease_id AND i.species_id = #{@species_id} AND p.species_id = #{@species_id};"
    i_result =  ActiveRecord::Base.connection.execute(i_query);
    i_result.each{|x|
      add_edge(x[0], x[1], 0)
      }
  end
    
    
  # add edges to the graph g
  def add_edge(x, y, pos)
    # if graph doesn't have node, add it
    if(!@g.has_key?(x)) then 
      @g[x] = []
    end
    # if graph doesn't have edge, add it (this also is executed if the node was just added)
    if(!@g[x].include? y) then
      @g[x] << {:id => y, :pos => pos}
    end
  end
    
    
  # show all edges (list of lists)
  def print
    @g.each{|k,v|
      puts k.to_s + " --> " + v.collect{|v| v.values.join("_")}.join(",")
    }
  end
    
  def test
    "path works"
  end

end





