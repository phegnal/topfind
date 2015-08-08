namespace :export_nterminome do

  # these tasks extract data on N-termini from TopFIND. In particular, the position and evidences for the termini for metaanlaysis of the data in other programs (R)

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
  task :nters, [:speciesID] do |t, args|
    require "#{RAILS_ROOT}/config/environment"
    
    date = Time.new.strftime("%Y_%m_%d")
    nterHash = {}
    
    # add signal/peptide removal?
    # domains lost?
    
    keys = [:obs, :can, :dir, :tis, :ensembl, :cleaved, :isoform]
    
    Protein.find(:all, :conditions => ["species_id = ?", args[:speciesID].to_i]).each_with_index{|p, i|
      # break if i > 20
      if not p.ac.include? "-"
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
                if e.name =~ /^Inferred from cleavage/ #tested here for the ones with e.evidencesource == nil and below for the ones where there is an evidencesource
                  nterHash[p.ac][n.pos][:cleaved] = true
                else
                  nterHash[p.ac][n.pos][:obs] = nterHash[p.ac][n.pos][:obs].to_s + "_" + e.id.to_s
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
                nterHash[p.ac][n.pos][:isoform] = true
              elsif e.name =~ /^Inferred from cleavage/
                  nterHash[p.ac][n.pos][:cleaved] = true
              end
            end
          }
        }
      end
    }
    
    # WRITE TO OUTPUT
    output = File.new("#{date}_ntermini_species#{args[:speciesID]}.txt", "w")
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
  end
    
    
  
  #
  #
  # goes through the file and combines positions if close
  #
  #
  #  
  # TAKES ORIGINAL OUTPUT AND MERGES TERMINI
  desc "Take N-termini file and merge with positions that are close (N- and C-terminal! not ideal probably)"
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
          nterHash[ac][pos][keys[ind+2]] = (l[ind+2] != "false") # this should work for the obs too, which is now e.id for obs
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
      startPos = nil
      while(pos != []) do
        currentPos = pos.shift
        currentData = nterHash[ac][currentPos]
        if currentPos <= (lastPos + dist) # merge entries if they are that close
          lastData.keys.each{|k| lastData[k] = (lastData[k] or currentData[k])}
        else # make new entry
          nTerHash2[ac]["#{startPos.to_s}_#{lastPos.to_s}"] = lastData if not lastData.nil? # safe old last entries the "if not" is for the first run
          lastData = nterHash[ac][currentPos] # create first data for new entry
          startPos = currentPos # define startPos for new entry
        end
        lastPos = currentPos
      end
      nTerHash2[ac]["#{startPos.to_s}_#{lastPos.to_s}"] = lastData # the last left over row
    }

    # WRITE SECOND OUTPUT TO OUTPUT2
    date = Time.new.strftime("%Y_%m_%d")
    output2 = File.new("#{args[:file]}_mergedBy#{args[:merge_distance]}.txt", "w")
    # HEADER
    valKeys = keys[2..(keys.length-1)]
    output2 << "ac\tstartPos\tendPos\t"
    output2 << valKeys.join("\t")
    output2 << "\n"
    # CONTENT
    nTerHash2.keys.each{|ac|
      nTerHash2[ac].keys.each{|pos|
        posSplit = pos.split("_")
        output2 << "#{ac}\t#{posSplit[0]}\t#{posSplit[1]}\t"
        output2 << valKeys.collect{|k| nTerHash2[ac][pos][k]}.join("\t")
        output2 << "\n"
      }
    }
    # close output
    output2.close
    
    
  end
  
  
  #
  #
  # goes through the proteins and writes a table of signal peptides positions and propeptide positions
  #
  #
  #
  #
  desc "Get positions of signal and propeptide for all proteins"
  task :addMaturePosition, [:file] do |t, args|
    require "#{RAILS_ROOT}/config/environment"

    date = Time.new.strftime("%Y_%m_%d")    
      
    # get Signal and Pro peptide coordinates
    sHash = {}    
    sig_query = "select p.ac as ac, f.from as fromx, f.to as tox from fts f, proteins p where f.name in ('SIGNAL', 'PROPEP') and p.id = f.protein_id;"
    sig_result =  ActiveRecord::Base.connection.execute(sig_query);
    sig_result.each{|x| 
      sHash[x[0]] = [] if not sHash.has_key?(x[0])
      sHash[x[0]] << {:from => x[1].to_i, :to => x[2].to_i}
    }
    
    # return distance of termini from signal and propeptide
    inputFile = File.new(args[:file], "r")
    output = File.new("#{args[:file]}_SigProPeptideDist.txt", "w")
    inputFile.each_with_index{|line, i|
      if i == 0
        output << "#{line.rstrip}\tmatureDistance\n"
      else
        l = line.rstrip.split("\t")
        ac = l[0]
        xRange = (l[1].to_i..l[2].to_i).to_a
        newDistance = "NA"
        if not sHash[ac].nil?
          newDistance = sHash[ac].collect{|pep| (pep[:from]..pep[:to]).to_a}.select{|pepRange| pepRange.length > 0}.collect{|pepRange|
            if xRange.collect{|x| pepRange.include?(x)}.any? # they overlap
              0
            elsif xRange.min() > pepRange.max()
              xRange.min() - pepRange.max()
            elsif pepRange.min() > xRange.max()
              pepRange.min() - xRange.max()
            else
              p "ERROR"
              p xRange
              p pepRange
            end
          }.min().to_s
        end
        output << "#{line.rstrip}\t#{newDistance}\n"
      end
    }
    inputFile.close
    output.close

  end
  
  
  # Below are additional methods to the first update program, to get information only for observed N-termini and focus evidence on those. Contrary to the older program, here I will extract evidences only N-TERMINAL to the observed N-terminus, because those are the processes that could have cause the N-terminus through ragging.
  
  
  
  #
  #
  # goes through the file and combines positions if close
  #
  #
  #  
  # TAKES ORIGINAL OUTPUT AND MERGES TERMINI
  desc "Take N-termini file and merge observed N-termini with evidence found before (only n-terminal)"
  task :merge_nters2, [:file, :merge_distance] do |t, args|

    # READ ORIGINAL OUTPUT
    inputFile = File.new(args[:file], "r")
    nTerHash = {}
    keys = []
    i = 0
    inputFile.each{|line|
      l = line.rstrip.split("\t")
      if i == 0 
        keys = l
      else
        ac = l[0]
        pos = l[1].to_i
        nTerHash[ac] = {} if nTerHash[ac].nil?
        nTerHash[ac][pos] = {} if nTerHash[ac][pos].nil?
        l[2..(l.length-1)].each_index{|ind|
          nTerHash[ac][pos][keys[ind+2]] = (l[ind+2] == "true")
        }
      end
      i += 1
    }
    inputFile.close()

    # GET SECOND OUTPUT MERGED FOR MANY POSITIONS
    dist = args[:merge_distance].to_i
    nTerHash2 = {}
    nTerHash.keys.each{|ac|
      nTerHash2[ac] = {}
      pos = nTerHash[ac].keys.sort{|a,b| a <=> b}
      lastData = nil # initiate with first protein
      lastPos = -50 # so that first run goes into else
      startPos = nil
      obsEntryData = nil
      obsEntryEndPos = nil
      while(pos != []) do
        currentPos = pos.shift
        currentData = nTerHash[ac][currentPos]
        # if it's close, then merge
        if currentPos <= (lastPos + dist) # merge entries if they are that close
          lastData.keys.each{|k| lastData[k] = (lastData[k] or currentData[k])}
        # if it's far, then make new entry
        else # make new entry
          nTerHash2[ac]["#{startPos.to_s}_#{obsEntryEndPos.to_s}"] = obsEntryData if not obsEntryData.nil? # safe old last entries the "if not" is for the first run
          obsEntryData = nil
          obsEntryEndPos = nil
          lastData = nTerHash[ac][currentPos] # create first data for new entry
          startPos = currentPos # define startPos for new entry
        end
        if lastData["obs"]
          obsEntryData = lastData
          obsEntryEndPos = currentPos
        end
        
        lastPos = currentPos
      end
      nTerHash2[ac]["#{startPos.to_s}_#{obsEntryEndPos.to_s}"] = obsEntryData if not obsEntryData.nil? # the last left over row
    }

    # WRITE SECOND OUTPUT TO OUTPUT2
    date = Time.new.strftime("%Y_%m_%d")
    output2 = File.new("#{args[:file]}_mergedBy#{args[:merge_distance]}_byObs.txt", "w")
    # HEADER
    valKeys = keys[2..(keys.length-1)]
    output2 << "ac\tstartPos\tendPos\t"
    output2 << valKeys.join("\t")
    output2 << "\n"
    # CONTENT
    nTerHash2.keys.each{|ac|
      nTerHash2[ac].keys.each{|pos|
        posSplit = pos.split("_")
        output2 << "#{ac}\t#{posSplit[0]}\t#{posSplit[1]}\t"
        output2 << valKeys.collect{|k| nTerHash2[ac][pos][k]}.join("\t")
        output2 << "\n"
      }
    }
    # close output
    output2.close
    
    
  end
  
  
  #
  #
  # goes through the proteins and writes a table of signal peptides positions and propeptide positions
  #
  #
  #
  #
  desc "Get positions of signal and propeptide for all proteins"
  task :addMaturePosition2, [:file] do |t, args|
    require "#{RAILS_ROOT}/config/environment"

    date = Time.new.strftime("%Y_%m_%d")    
      
    # get Signal and Pro peptide coordinates
    sHash = {}    
    sig_query = "select p.ac as ac, f.from as fromx, f.to as tox from fts f, proteins p where f.name in ('SIGNAL', 'PROPEP') and p.id = f.protein_id;"
    sig_result =  ActiveRecord::Base.connection.execute(sig_query);
    sig_result.each{|x| 
      sHash[x[0]] = [] if not sHash.has_key?(x[0])
      sHash[x[0]] << {:from => x[1].to_i, :to => x[2].to_i}
    }
    
    # return distance of termini from signal and propeptide
    inputFile = File.new(args[:file], "r")
    output = File.new("#{args[:file]}_SigProPeptideDist.txt", "w")
    inputFile.each_with_index{|line, i|
      if i == 0
        output << "#{line.rstrip}\tmatureDistance\n"
      else
        l = line.rstrip.split("\t")
        ac = l[0]
        xRange = (l[1].to_i..l[2].to_i).to_a
        p xRange
        newDistance = "NA"
        if not sHash[ac].nil?
          newDistance = sHash[ac].collect{|pep| (pep[:from]..pep[:to]).to_a}.select{|pepRange| pepRange.length > 0}.collect{|pepRange|
            if xRange.collect{|x| pepRange.include?(x)}.any? # they overlap
              0
            elsif xRange.min() > pepRange.max()
              xRange.min() - pepRange.max()
            elsif pepRange.min() > xRange.max()
              pepRange.min() - xRange.max()
            else
              p "ERROR"
              p xRange
              p pepRange
            end
          }.min().to_s
        end
        output << "#{line.rstrip}\t#{newDistance}\n"
      end
    }
    inputFile.close
    output.close

  end
  
end