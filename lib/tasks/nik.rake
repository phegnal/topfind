namespace :nik do


  # TEST TASK
  #
  desc "test that this file is read"
  task :test do
    puts "test works"    
  end

  
  # MASTER UPDATE TASK
  #
  # 
  desc "Read n termini from topfind and write them to file"
  task :nters do
    require "#{RAILS_ROOT}/config/environment"
    
    date = Time.new.strftime("%Y_%m_%d")
    nterHash = {}
    
    # add signal/peptide removal?
    # domains lost?
    
    keys = [:obs, :can, :dir, :tis, :ensembl, :cleaved, :isoform]
    
    Protein.find(:all, :conditions => ["species_id = ?", 1]).each_with_index{|p, i|
      # break if i > 20
      nterHash[p.ac] = {}
      p.nterms.each{|n|
        if nterHash[p.ac][n.pos].nil?
          nterHash[p.ac][n.pos] = {}
          keys.each{|k| nterHash[p.ac][n.pos][k] = false}
        end
        Nterm2evidence.find(:all, :conditions => ['nterm_id = ?', n.id]).each{|n2e|
          # here i could annotated n-terminus (acetylated, signal/propetide removed, ...?)
          # p "#{p.ac} #{n.pos}"
          e = n2e.evidence
          if not e.nil?
            if e.evidencesource.nil?
              if e.name =~ /^Inferred from cleavage/
                nterHash[p.ac][n.pos][:cleaved] = true
              else
                nterHash[p.ac][n.pos][:obs] = true
                nterHash[p.ac][n.pos][:dir] = true if e.directness == "direct"            
              end
            elsif e.evidencesource.dbname == "MEROPS"
              nterHash[p.ac][n.pos][:cleaved] = true
            elsif e.evidencesource.dbname == "UniProtKB"
              nterHash[p.ac][n.pos][:can] = true            
            elsif e.evidencesource.dbname == "TISdb"
              nterHash[p.ac][n.pos][:tis] = true
            elsif e.evidencesource.dbname == "Ensembl"
              nterHash[p.ac][n.pos][:ensembl] = true
            elsif e.evidencecodes.collect{|s| s.code}.include? "TopFIND:0000002"
              @q[:isoform] << e
            end
          end
        }
      }
    }
    
    # WRITE TO OUTPUT
    output = File.new("#{date}_ntermini.txt", "w")
    # HEADER
    output << "ac\tpos\t"
    output << keys.join("\t")
    output << "\n"
    # CONTENT
    nterHash.keys.each{|ac|
      nterHash[ac].keys.each{|pos|
        output << "#{ac}\t#{pos}\t"
        output << keys.collect{|k| nterHash[ac][pos][k]}.join("\t")
        output << "\n"
      }
    }
    # close output
    output.close
    
    p "Ntermini found, now starting to merge them by position"
  end
    
    
    
  # TAKES ORIGINAL OUTPUT AND MERGES TERMINI
  desc "Take N-termini file and merge with positions that are close"
  task :merge_nters, [:file, :merge_distance] do |t, args|

    # READ ORIGINAL OUTPUT
    inputFile = File.new(args[:file], "r")
    nterHash = {}
    keys = []
    i = 0
    inputFile.each{|line|
      l = line.rstrip.split("\t")
      if i == 0 
        keys = l
      else
        ac = l[0]
        pos = l[1].to_i
        nterHash[ac] = {} if nterHash[ac].nil?
        nterHash[ac][pos] = {} if nterHash[ac][pos].nil?
        l[2..(l.length-1)].each_index{|ind|
          nterHash[ac][pos][keys[ind+2]] = (l[ind+2] == "true")
        }
      end
      i += 1
    }
    inputFile.close()

    # GET SECOND OUTPUT MERGED FOR MANY POSITIONS
    dist = args[:merge_distance].to_i
    nTerHash2 = {}
    nterHash.keys.each{|ac|
      nTerHash2[ac] = {}
      pos = nterHash[ac].keys.sort{|a,b| a <=> b}
      lastData = nil # initiate with first protein
      lastPos = -50 # so that first run goes into else
      while(pos != []) do
        currentPos = pos.shift
        currentData = nterHash[ac][currentPos]
        if currentPos <= (lastPos + dist) # merge entries if they are that close
          lastData.keys.each{|k| lastData[k] = (lastData[k] or currentData[k])}
        else # make new entry
          nTerHash2[ac][lastPos] = lastData if not lastData.nil? # the "if not" is for the first run
          lastData = nterHash[ac][currentPos]
        end
        lastPos = currentPos
      end
      nTerHash2[ac][lastPos] = lastData # the last left over row
    }

    # WRITE SECOND OUTPUT TO OUTPUT2
    date = Time.new.strftime("%Y_%m_%d")
    output2 = File.new("#{date}_ntermini2.txt", "w")
    # HEADER
    valKeys = keys[2..(keys.length-1)]
    output2 << "ac\tpos\t"
    output2 << valKeys.join("\t")
    output2 << "\n"
    # CONTENT
    nTerHash2.keys.each{|ac|
      nTerHash2[ac].keys.each{|pos|
        output2 << "#{ac}\t#{pos}\t"
        output2 << valKeys.collect{|k| nTerHash2[ac][pos][k]}.join("\t")
        output2 << "\n"
      }
    }
    # close output
    output2.close
    
    
  end

end