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
  desc "go through organisms and add N-termini for each from TISdb"
  task :nters do
    require "#{RAILS_ROOT}/config/environment"
    
    date = Time.new.strftime("%Y_%m_%d")
    nterHash = {}
    
    # add signal/peptide removal?
    # domains lost?
    
    keys = [:obs, :can, :dir, :tis, :splice, :cleaved]
    
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
              nterHash[p.ac][n.pos][:splice] = true
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
    
    # write a program to read the file and to do this modification afterwards
  #   l = line.split("\t")
  #   newHash = {}
  #   if i == 1
  #   keys = l
  # else
  #   line = {}
  #   key.each_index{|i| line[keys[i]] = l[i]}
  #   newHash[line["ac"]] = {} if newHash[line["ac"]].nil?
  #   newHash[line["ac"]][line["pos"]] =
    
    
    # GET SECOND OUTPUT MERGED FOR MANY POSITIONS
    nTerHash2 = {}
    nterHash.keys.each{|ac|
      nTerHash2[ac] = {}
      pos = nterHash[ac].keys.sort{|a,b| a <=> b} 
      current = nil # initiate with first protein
      s = -50 # so that first run goes into else
      while(pos != []) do
        p = pos.shift
        if p <= (s + 3)
          # merge entries
          current.keys.each{|k| current[:k] = current[:k] or nterHash[ac][p][:k]}
        else
          # make new entry
          nTerHash2[ac][p] = current if not current.nil? # the "if not" is for the first run
          current = nterHash[ac][p]
        end
        s = p
      end
    }

    # WRITE SECOND OUTPUT TO OUTPUT2
    output2 = File.new("#{date}_ntermini2.txt", "w")
    # HEADER
    output2 << "ac\tpos\t"
    output2 << keys.join("\t")
    output2 << "\n"
    # CONTENT
    nTerHash2.keys.each{|ac|
      nTerHash2[ac].keys.each{|pos|
        output2 << "#{ac}\t#{pos}\t"
        output2 << keys.collect{|k| nTerHash2[ac][pos][k]}.join("\t")
        output2 << "\n"
      }
    }
    # close output
    output2.close
    
    
  end

end















