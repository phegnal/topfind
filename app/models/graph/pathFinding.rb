# additional functionalities:
# - final step at the right position
# - 
class PathFinding

  require 'graph/mapMouseHuman'


def initialize(graph, maxSteps)
  @g = graph.graph_array()
  @allPaths = Hash.new
  @maxSteps = maxSteps
end


## FOR ALL METHODS BELOW:
##
## start is one protein AC
## target is an array of hashes, each has 
## => (1) id - uniprot AC
## => (2) pos - position

def find_all_paths_map2mouse(start, targets)
  mapper = MapMouseHuman.new()
  return find_all_paths(mapper.m4h(start), targets.collect{|hash| {:id => mapper.m4h(hash[:id]), :pos => hash[:pos]}})
end

def find_all_paths_map2human(start, targets)
  mapper = MapMouseHuman.new()
  return find_all_paths(mapper.h4m(start), targets.collect{|hash| {:id => mapper.h4m(hash[:id]), :pos => hash[:pos]}})
end

def find_all_paths(start, targets)
  targets.each{|target|
    res = find_all_paths_for_one(start, target)
    @allPaths[target] = res.clone
  }
  return @allPaths
end

def find_all_paths_for_one(start, target)
  @ListOfPaths = []
  find_path({:id => start, :pos => -1}, target, []) # starts with empty path
  result = @ListOfPaths.clone
  @ListOfPaths = []
  return result
end

# current is also a hash as defined above 
def find_path(current, target, currentPath) # current vertex (recursive!), target(ultimate target), current path
  currentPath << current
  # look at successors of current
  successors = @g[current[:id]]
  if(successors != nil && successors.class.to_s == "Array") then 
    successors.each{|x|
      if(x[:id] == target[:id]) then # THIS IS WHERE POSITION COULD COME INTO PLAY! TODO
        toSubmit = currentPath.clone # needs to be cloned!
        toSubmit << x
        @ListOfPaths << toSubmit # add one found path
      
      # continue the search from this node if 
      #  - the node is not in the path AND
      #  - the path length is smaller than 3 (ultimately max 5)
      elsif(!currentPath.include?(x) && currentPath.length < (@maxSteps-1)) then
        find_path(x, target, currentPath)
      end
    }
  end
  # after analyzing all successors, go back up the path one step
  currentPath.pop
end

def test
  puts "pathfinding works"
end

def paths_gene_names()
  proteins = (@allPaths.values.flatten + @allPaths.keys)
  proteins = proteins.collect{|hash| hash[:id]}.uniq
  return get_gene_names(proteins)
end

def get_gene_names(proteins)
  @gnames = {}
  g_query = 'select  p.ac, g.name from proteins p, gns g where g.protein_id = p.id and p.ac in ("' + proteins.join('", "') + '") ;'
  g_result =  ActiveRecord::Base.connection.execute(g_query);
  g_result.each{|x|
    @gnames[x[0]] = x[1]
  }
  return @gnames
end

end