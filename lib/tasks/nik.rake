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
    output = File.new("#{date}_ntermini.txt", "w")
    x = {}
    
    # add signal/peptide removal?
    # domains lost?
    
    keys = [:obs, :can, :dir, :tis, :splice, :cleaved]
    
    Protein.find(:all, :conditions => ["species_id = ?", 1]).each_with_index{|p, i|
      # break if i > 20
      x[p.ac] = {}
      p.nterms.each{|n|
        if x[p.ac][n.pos].nil?
          x[p.ac][n.pos] = {}
          keys.each{|k| x[p.ac][n.pos][k] = false}
        end
        Nterm2evidence.find(:all, :conditions => ['nterm_id = ?', n.id]).each{|n2e|
          # here i could annotated n-terminus (acetylated, signal/propetide removed, ...?)
          # p "#{p.ac} #{n.pos}"
          e = n2e.evidence
          if not e.nil?
            if e.evidencesource.nil?
              if e.name =~ /^Inferred from cleavage/
                x[p.ac][n.pos][:cleaved] = true
              else
                x[p.ac][n.pos][:obs] = true
                x[p.ac][n.pos][:dir] = true if e.directness == "direct"            
              end
            elsif e.evidencesource.dbname == "MEROPS"
              x[p.ac][n.pos][:cleaved] = true
            elsif e.evidencesource.dbname == "UniProtKB"
              x[p.ac][n.pos][:can] = true            
            elsif e.evidencesource.dbname == "TISdb"
              x[p.ac][n.pos][:tis] = true
            elsif e.evidencesource.dbname == "Ensembl"
              x[p.ac][n.pos][:splice] = true
            end
          end
        }
      }
    }
    
    # WRITE TO OUTPUT
    # HEADER
    output << "ac\tpos\t"
    output << keys.join("\t")
    output << "\n"
    # CONTENT
    x.keys.each{|ac|
      x[ac].keys.each{|pos|
        output << "#{ac}\t#{pos}\t"
        output << keys.collect{|k| x[ac][pos][k]}.join("\t")
        output << "\n"
      }
    }
    
    output.close
    
  end

end