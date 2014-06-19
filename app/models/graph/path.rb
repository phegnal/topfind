class Path
    
    require 'graph/pathFinding'
    
  def initialize(maxSteps)
    @finder = PathFinding.new(maxSteps)
  end
    
  def test
    "path works"
  end
  
  def get_gene_names(proteins)
      names = {}
      g_query = 'select  p.ac, g.name from proteins p, gns g where g.protein_id = p.id and p.ac in ("' + proteins.join('", "') + '") ;'
      g_result =  ActiveRecord::Base.connection.execute(g_query);
      g_result.each{|x|
        names[x[0]] = x[1]
      }
      names
  end
  
  def graph_from_sql(species_id)     
    c_query = "SELECT p.ac as protease, s.ac as substrate from cleavages c, proteins p, proteins s WHERE p.id = c.protease_id AND s.id = c.substrate_id AND p.species_id = #{species_id} AND s.species_id = #{species_id};"
    c_result =  ActiveRecord::Base.connection.execute(c_query);
    c_result.each{|x| 
      @finder.add_edge(x[0], x[1])
      }
    
    i_query = "SELECT i.ac as inhibitor, p.ac as protease from inhibitions inh, proteins i, proteins p WHERE i.id = inh.inhibitor_id AND p.id = inh.inhibited_protease_id AND i.species_id = #{species_id} AND p.species_id = #{species_id};"
    i_result =  ActiveRecord::Base.connection.execute(i_query);
    i_result.each{|x|
      @finder.add_edge(x[0], x[1])
      }
  end
  
  def find_paths(start, target)
     @finder.find_all_paths(start, target)
     
     #@name_map = 
  end

end