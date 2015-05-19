class PathFinding

  require 'graph/mapMouseHuman'

  def initialize(graph, maxSteps, byPos, rangeLeft, rangeRight, infer_target_edges)
    @g = graph
    @maxSteps = maxSteps
    @byPos = byPos # defines whether the target has to be hit at exactly that position
    @rangeLeft = rangeLeft
    @rangeRight = rangeRight
    @@infer_target_edges = infer_target_edges
    @@g2 = nil
  end


  ## FOR ALL METHODS BELOW:
  ##
  ## start is one protein AC
  ## target is an array of hashes, each has 
  ## => (1) id - uniprot AC
  ## => (2) pos - position
  
  def find_all_paths_map2mouse(start, targets)
    mapper = MapMouseHuman.new()
    mousetargets = targets.collect{|hash| mapper.m4h(hash[:id]).collect{|mid| {:id => mid, :pos => hash[:pos]} }}.flatten
    return find_all_paths(mapper.m4h(start)[0], mousetargets)
  end

  def find_all_paths_map2human(start, targets)
    mapper = MapMouseHuman.new()
    humantargets = targets.collect{|hash| mapper.h4m(hash[:id]).collect{|hid| {:id => hid, :pos => hash[:pos]} }}.flatten
    return find_all_paths(mapper.h4m(start)[0], humantargets)
  end

  # find paths from start protease to one target
  def find_all_paths_for_one(start, target)
    find_all_paths(start, [target])
    return @allPaths[target[:id]+"_"+target[:pos].to_s]
  end
  
  # find paths from start protease to all targets
  def find_all_paths(start, targets)
    @allPaths = Hash.new
    @@g2 = @g.clone()
    targets.each{|p| @@g2.add_edge(start, p[:id], p[:pos], "l")} if @@infer_target_edges
    @@g2 = @@g2.graph_array()
    if not Protein.find_by_ac(start).nil?
      targets.each{|t| @allPaths[t[:id]+"_"+t[:pos].to_s] = []}
      # limit targets to those in the graph
      graphids = (@@g2.keys + @@g2.values.collect{|s| s.collect{|x| x[:id]}}.flatten).uniq
      targets2 = targets.select{|t| graphids.include? t[:id]}
      p "start protease not found #{start}" if not graphids.include? start
      # look for targets in the graph
      find_all_for_targets({:id => start, :pos => -1, :type => "s"}, targets2, [], start)
    else
      targets.each{|target| @allPaths[target[:id]+"_"+target[:pos].to_s] = [{:id => "Start protease not found", :pos => 0, :type => "s"}] }
    end
    return @allPaths
  end

  # recursive method that goes through the graph and looks for all paths from start to targets
  # call first time with currentPath = []
  def find_all_for_targets(current, targets, currentPath, start)
    currentPath << current
    # look at successors of current
    successors = @@g2[current[:id]]
    if(successors != nil && successors.class.to_s == "Array")
      successors.each{|s|
        next if s[:id] == start
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
          find_all_for_targets(s, targets, currentPath, start)
        end
      }
    end
    # after analyzing all successors, go back up the path one step
    currentPath.pop
  end
  
  def remove_direct_paths()
    @allPaths.each_pair{|k ,v| @allPaths[k] = v.select{|path| path.collect{|x| x[:id]}.uniq.length > 2}}
  end
  
  def get_paths()
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
    @gnames.keys.select{|k| @gnames[k].nil?}.each{|k| @gnames[k] = k }
    return @gnames
  end

  def get_domain_info(domains_names_filter, domains_descriptions_filter)
    
    path_proteins = @allPaths.values.collect{|path_set|
      path_set.collect{|path|
        path.collect{|target|
          target[:id]
        }
      }
    }.flatten.uniq
    
    fts_hash = {}
    
    path_proteins.each{|p| 
      f = []
      feats = Protein.find_by_ac(p).fts
      f.concat(feats.find_all_by_name(domains_names_filter)) if not domains_names_filter.nil?
      f.concat(feats.find(:all, :conditions => [Array.new(domains_descriptions_filter.length, "description LIKE ?").join(" OR "), domains_descriptions_filter].flatten)) if not domains_descriptions_filter.nil?
      fts_hash[p] = f
    }
    
    @allPaths.each_value{|path_set|
      path_set.each{|path|
        path.each{|target|
          f = fts_hash[target[:id]]
          f = f.sort{|x,y| x.from.to_i <=> y.from.to_i}
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
    File.delete("#{folder}/pw_graphviz.txt") if File.exist?("#{folder}/pw_graphviz.txt")
    File.delete("#{folder}/pw_graphviz.svg") if File.exist?("#{folder}/pw_graphviz.svg")
    firstNode = @allPaths.values.select{|pathset| pathset != []}.collect{|pathset| pathset[0][0]}.uniq[0] # get first element of any path
    if not firstNode.nil?   # WRITES Graphviz only if there was any path (so there was a first element somewhere)
      nodestyles=["#{gnames[firstNode[:id]]} [style=filled fillcolor=turquoise];\n"]
      edges = []
      pathnodes = @allPaths.values.collect{|pathset| pathset.collect{|path| path.collect{|node| node[:id]}}}.flatten.uniq
      @allPaths.keys.each{|k| 
        if pathnodes.include?(k.split("_")[0])
          nodestyles << "#{gnames[k.split("_")[0]]} [style=filled fillcolor=grey];\n"  
        end
      }
      @allPaths.values.each{|pathset| pathset.each{|path|
        (1..path.length-1).each{|i| 
          edgestring = "#{gnames[path[i-1][:id]]} -> #{gnames[path[i][:id]]}" 
          if path[i][:type] == "i"
              edgestring += '[label=inh, arrowhead = tee]' 
            elsif path[i][:type] == "c"
              edgestring += "[label=#{path[i][:pos]} style=bold];"
            else
              edgestring += "[label=#{path[i][:pos]} style=dotted];"
            end
          edgestring += "\n"
                  edges << edgestring
        }}}
      outputFile = File.open("#{folder}/pw_graphviz.txt", "w")
      outputFile << "digraph G {\n"
      nodestyles.uniq.each{|e| outputFile << e}
      outputFile << "edge [style=bold  color=grey labelfontname=Arial];\n"
      legend = <<EOS
      subgraph cluster_1 {
      		label = Legend;
      		color=black;
      		"query protease" [style=filled fillcolor=turquoise];		
      		"list member " [style=filled fillcolor=grey];
      		inhibitor -> protease [label="inhibition (inh)", arrowhead = tee];
      		protease -> substrate [label="cleavage (position indicated)"];
      }
EOS
      outputFile << legend
      edges.flatten.uniq.each{|e| outputFile << e}
      outputFile << "}"
      outputFile.close
    end
    
    x = nil
    x = system "dot #{folder}/pw_graphviz.txt -Tsvg -o #{folder}/pw_graphviz.svg 2>#{folder}/pw_errorlog.txt" if File.exist?("#{folder}/pw_graphviz.txt")
	return(x)
  end
  
  
end