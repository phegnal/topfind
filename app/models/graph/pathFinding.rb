class PathFinding

  require 'graph/mapMouseHuman'

  def initialize(graph, maxSteps, byPos, rangeLeft, rangeRight)
    @g = graph.graph_array()
    @maxSteps = maxSteps
    @byPos = byPos # defines whether the target has to be hit at exactly that position
    @rangeLeft = rangeLeft
    @rangeRight = rangeRight
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

  # find paths from start protease to one target
  def find_all_paths_for_one(start, target)
    find_all_paths(start, [target])
    return @allPaths[target[:id]+"_"+target[:pos].to_s]
  end
  
  # find paths from start protease to all targets
  def find_all_paths(start, targets)
    @allPaths = Hash.new
    if not Protein.find_by_ac(start).nil?
      targets.each{|t| @allPaths[t[:id]+"_"+t[:pos].to_s] = []}
      # limit targets to those in the graph
      graphids = (@g.keys + @g.values.collect{|s| s.collect{|x| x[:id]}}.flatten).uniq
      targets2 = targets.select{|t| graphids.include? t[:id]}
      # look for targets in the graph
      find_all_for_targets({:id => start, :pos => -1}, targets2, [])
    else
      targets.each{|target| @allPaths[target[:id]+"_"+target[:pos].to_s] = [{:id => "Start protease not found", :pos => 0}] }
    end
    return @allPaths
  end

  # recursive method that goes through the graph and looks for all paths from start to targets
  # call first time with currentPath = []
  def find_all_for_targets(current, targets, currentPath)
    currentPath << current
    # look at successors of current
    successors = @g[current[:id]]
    if(successors != nil && successors.class.to_s == "Array")
      successors.each{|s|
        # find hits (targets that correspond to s)
        hits = targets.select{|t| 
          @byPos ? (s[:id] == t[:id] && ((t[:pos]-@rangeLeft..t[:pos]+@rangeRight).to_a.include? s[:pos])) : (s[:id] == t[:id])
        }
        toSubmit = currentPath.clone # needs to be cloned!
        toSubmit << s
        # add paths for the hits
        hits.each{|t|  @allPaths[t[:id]+"_"+t[:pos].to_s] << toSubmit }
        # continue the search from this node if the node is not in the path AND the path length is smaller than the maximal steps
        if(!currentPath.include?(s) && currentPath.length < (@maxSteps-1)) 
          # recursive call
          find_all_for_targets(s, targets, currentPath)
        end
      }
    end
    # after analyzing all successors, go back up the path one step
    currentPath.pop
    return @allPaths
  end

  def test
    puts "pathfinding works"
  end

  def paths_gene_names()
    return get_gene_names( (@allPaths.values.flatten.collect{|hash| hash[:id]} + @allPaths.keys.collect{|k| k.split("_")[0]}).uniq)
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

  def get_domain_info(domains_names, domains_descriptions)
    @allPaths.each_value{|path_set|
      path_set.each{|path|
        path.each{|target|
          f = []
          feats = Protein.find_by_ac(target[:id]).fts
          f.concat(feats.find_all_by_name(domains_names)) if not domains_names.nil?
          f.concat(feats.find(:all, :conditions => [Array.new(domains_descriptions.length, "description LIKE ?").join(" OR "), domains_descriptions].flatten)) if not domains_descriptions.nil?
          
          target[:domains_left] = f.select{|x| x.to.to_i < target[:pos]}
          target[:domains_hit] = f.select{|x| x.from.to_i <= target[:pos] && x.to.to_i >= target[:pos]}
          target[:domains_right] = f.select{|x| x.from.to_i > target[:pos]}
        }
      }
    }
    return @allPaths
  end
  
  # takes the @allPaths from this method and makes a graphviz file
  # returns the file path for the graphviz file or nil if it didn't work
  #
  def make_graphviz(folder, gnames)
  firstNode = @allPaths.values.select{|pathset| pathset != []}.collect{|pathset| pathset[0][0]}.uniq[0] # get first element of any path
  if not firstNode.nil?   # WRITES Graphviz only if there was any path (so there was a first element somewhere)
    nodestyles=["#{gnames[firstNode[:id]]} [style=filled fillcolor=turquoise];\n"]
    edges = []
    @allPaths.values.each{|pathset| pathset.each{|path|
      nodestyles << "#{gnames[path[path.length-1][:id]]} [style=filled fillcolor=grey];\n"
      (1..path.length-1).each{|i| edges << "#{gnames[path[i-1][:id]]} -> #{gnames[path[i][:id]]} [label=#{path[i][:pos] == 0 ? 'inh' : path[i][:pos]}];\n"
      }}}
      outputFile = File.open("#{folder}/pw_graphviz.txt", "w")
      outputFile << "digraph G {\n"
      nodestyles.uniq.each{|e| outputFile << e}
      outputFile << "edge [style=bold  color=grey labelfontname=Arial];\n"
      edges.flatten.uniq.each{|e| outputFile << e}
      outputFile << "}"
      outputFile.close
    end
    return "#{folder}/pw_graphviz.pdf" if system "dot #{folder}/pw_graphviz.txt -Tpdf -o #{folder}/pw_graphviz.pdf"
  end
  
end