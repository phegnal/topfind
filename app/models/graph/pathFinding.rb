# additional functionalities:
# - final step at the right position
# - 
class PathFinding


def initialize(maxSteps)
  @g = {}
  @ListOfPaths = []
  @maxSteps = maxSteps
end


# add edges to the graph g
def add_edge(x, y)
  if(!@g.has_key?(x)) then 
    @g[x] = []
  end
  if(!@g[x].include? y) then
    @g[x] << y
  end
end


# show all edges (list of lists)
def print
  @g.each{|k,v|
    puts k.to_s + " --> " + v.join(",")
  }
end


def find_all_paths(start, target)
  find_path(start, target, [])
  result = @ListOfPaths.clone
  @ListOfPaths = []
  result
end


def find_path(current, target, currentPath) # current vertex (recursive!), target(ultimate target), current path
  currentPath << current
  # look at successors of current
  successors = @g[current]
  if(successors != nil && successors.class.to_s == "Array") then 
    successors.each{|x|
      if(x == target) then
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

end