namespace :tisDB_v1 do


  # TEST TASK
  #
  #
  #
  desc "test that this file is read"
  task :test do
    puts "test works"
  end

  
  # MASTER UPDATE TASK
  #
  # calls update for each organism
  #
  desc "go through organisms and add N-termini for each from TISdb"
  task :ntermini do
    require "#{RAILS_ROOT}/config/environment"
    
    date = Time.new.strftime("%Y_%m_%d")
    File.new("databases/TISdb/#{date}_logs.txt", "w").close
    
    species = Species.all
    species.each{|s|
      p s.id
      Rake::Task["tisDB_v1:ntermini_species"].execute(:species_id => s.id)
    }
    
  end

  # UPDATE TASK for one species
  #
  # calls update for one organism
  #
  desc "nTermini from TISdb for one species"
  task :ntermini_species, :species_id do |t, args|

    require "#{RAILS_ROOT}/config/environment"

    require "bio"

    ok = true

    speciesId = args[:species_id]
    speciesName = Species.find(speciesId).name
    
    outputFile = File.open(Time.new.strftime("databases/TISdb/%Y_%m_%d_logs.txt"), "a")
    
    outputFile << "\nProcessing " + speciesName + " ID: " + speciesId.to_s + "\n"
    
    #####
    ##### SEE IF TISdb csv FILES ARE THERE
    #####
    if ok
      case speciesName
      when "Homo sapiens"
        file = File.open("#{RAILS_ROOT}/databases/TISdb/TISdb_human_v1.0.csv")
      when "Mus musculus"
        file = File.open("#{RAILS_ROOT}/databases/TISdb/TISdb_mouse_v1.0.csv")
      else
        outputFile << "Species #{speciesName}, #{speciesId} cannot be processed \n"
        ok = false
      end
    end
    
    #####
    ##### GET TOPFIND ENSG AND SEQUENCE INFO
    #####   
    if ok
      g_query = "select distinct p.id, p.ac, g.name, p.sequence from proteins p, gns g where p.id = g.protein_id and p.species_id = #{speciesId};" # TODO
      g_result =  ActiveRecord::Base.connection.execute(g_query);
      genes = {}
      g_result.each{|x|
        if not x[2].nil?
          if not genes.has_key?(x[2])
            genes[x[2]] = []
          end
          genes[x[2]] << [x[0], x[1], x[3]] ## can have multiple proteins per ensg?!
        end
      }
      l = 0
      genes.each_value{|v|
        l = l + v.length
      }
      outputFile << speciesName + " - TopFIND: geneNames: " + genes.length.to_s + ", entries (geneName-Id pairs): " + l.to_s + "\n"
    end
        
    ####
    #### READ TIS DB FILES
    ####
    if ok
      tisdb = {}
      file.each{|line|
        l = line.split(",")
        if not l[0] == "gene"
          if l[9].to_i > 0
            if not tisdb.has_key?(l[0])
              tisdb[l[0]] = []
            end
            tisdb[l[0]] << {"id" => l[1], "pos" => l[9]}
          end
        end
      }
    end

    ###
    ### MAP to TOPFIND GENES
    ###
    if ok
      origLength = tisdb.length
      rm = tisdb.keys - genes.keys
      rm.each{|k|
        tisdb.delete(k)
      }
      ncbis = []
      tisdb.each_value{|v|
        v.each{|x|
          ncbis << x["id"]
        }
      }
      ncbis = ncbis.uniq
      outputFile << "#{tisdb.length} of #{origLength} genes found in TopFIND with #{ncbis.length} ncbi transcript ids \n"    
    
      ###
      ### GET SEQUENCES FROM NCBI
      ###
      Bio::NCBI.default_email = "a@bc.de" 
      ncbi = Bio::NCBI::REST::EFetch.new
      fastaString = ncbi.nucleotide(ncbis, "fasta")
      filePath = "#{RAILS_ROOT}/databases/TISdb/#{speciesName.gsub(/\s/, "_")}_download.fasta"
      File.open(filePath, 'w') {|f| f.write(fastaString) }
      fObj = Bio::FastaFormat.open(filePath)
      ncbiSequ = {}
      fObj.each{|f|
        id = f.identifiers.get('ref')
        if not id.nil? and f.seq().length > 5  
          ncbiSequ[id.gsub(/\.\d*/, "")] = f.seq()
        end
      }
      outputFile << "#{ncbiSequ.length} sequences found from NCBI \n"
    end
    
    #####
    ##### MAP ENSEMBL TO TOPFIND AND ADD N-TERMINI
    #####
    if ok    
      nters = []
      # cters = []

      ## map protein sequence to original sequence
      tisdb.keys.each_with_index{|g, ind|
        tisdb[g].each{|t|
          rnaSeq = ncbiSequ[t["id"]]
          if rnaSeq.nil?
            p "Sequence for #{t['id']} missing"
          else
            tSeq = rnaSeq[t['pos'].to_i-1, rnaSeq.length]            
            seq = Bio::Sequence::NA.new(tSeq).translate.split(/\*/)[0]
            genes[g].each{|topf|

              fullSeq = topf[2]
              ac = topf[1]
              id = topf[0]
              ### N - TERMINI
              # sl is the sequence length. This loop goes down the sequence from the back and tries to map it to the full sequence
              sl = seq.length
              while(true) do
                if sl < 20 ##### CUTOFF - CHECK TODO
                  break 
                end
                current_seq = seq[0,sl]
                case fullSeq.scan(/#{current_seq}/).length ## how many matches?
                when 1 
                  pos =  fullSeq.index(/#{current_seq}/)
                  if not pos.nil? and not pos == 0
                    nters << [g, t.id, pos, ac, id]
                  end
                  break
                when 0
                  sl = sl - 1
                  next
                else
                  outputFile << "#{g} #{t.id}...... mapped more than once - ignored \n"
                  break
                end
              end
            
              ### C - TERMINI
              # sstart is the start position. This loop goes up the sequence from the front and tries to map it to the full sequence
              # sstart = 0
              # current_seq = seq
              # while(true) do
              #   if current_seq.length < 20 ##### CUTOFF - CHECK TODO
              #     break 
              #   end
              #   current_seq = seq[sstart, seq.length]
              #   case fullSeq.scan(/#{current_seq}/).length ## how many matches?
              #   when 1 
              #     pos =  (fullSeq.index(/#{current_seq}/) + current_seq.length)
              #     if not pos.nil? and not pos == fullSeq.length
              #       cters << [g, t.id, pos, ac, id]
              #     end
              #     break
              #   when 0
              #     sstart = sstart + 1
              #     next
              #   else
              #     p "#{g} #{t.id}...... mapped more than once - ignored"
              #     break
              #   end
              # end
            }
          end
        }
      }
      
      outputFile << "#{nters.length} N-termini found \n"
      # p cters.length

      # # safe N-TERMINI in the database 
      nters.each{|r| 
        #p ("nter - " + r[0] + "  " + r[1].to_s + "  " +  r[2].to_s + "  " + r[3].to_s + " " + r[4])
        # find or create evidence
        @evidence = Evidence.find_or_create_by_name(:name => "inferred from TISdb",
        :idstring => "TISdb-ECO:0000203",
        :description => 'The stated informations has been extracted from the TISdb database.',
        :phys_relevance => 'unknown',
        :method => 'electronic annotation'
        )
        @evidence.evidencecodes << Evidencecode.code_is('ECO:0000203').first
        @evidence.evidencesource = Evidencesource.find_or_create_by_dbname(
        :dbname => 'TISdb',
        :dburl => 'http://tisdb.human.cornell.edu/',
        :dbdesc => 'TISdb'
        )
        @evidence.save
        # find or create N-terminus
        nmod = Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  # 
        nterm = Nterm.find_or_create_by_idstring(:idstring => "#{r[3]}-#{(r[2]+1).to_s}-#{nmod.name}",:protein_id => r[4], :pos => r[2]+1, :terminusmodification => nmod )
        nterm.evidences << @evidence
      }
      
      # safe C-TERMINI in the database
      # cters.each{|r| 
      #   p ("cter - " + r[0] + "  " + r[1].to_s + "  " +  r[2].to_s + "  " + r[3].to_s + " " + r[4])
      #   # find or create evidence
      #   @evidence = Evidence.find_or_create_by_name(:name => "inferred from TISdb",
      #     :idstring => "TISdb-ECO:0000203",
      #     :description => 'The stated informations has been extracted from the TISdb database.',
      #     :phys_relevance => 'unknown',
      #     :method => 'electronic annotation'
      #   )
      #   @evidence.evidencecodes << Evidencecode.code_is('ECO:0000203').first
      #   @evidence.evidencesource = Evidencesource.find_or_create_by_dbname(
      #     :dbname => 'TISdb',
      #     :dburl => 'http://tisdb.human.cornell.edu/',
      #     :dbdesc => 'TISdb'
      #   )
      #   @evidence.save
      #   # find or create N-terminus
      #   nmod = Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  # 
      #   nterm = Cterm.find_or_create_by_idstring(:idstring => "#{r[3]}-#{(r[2]).to_s}-#{nmod.name}",:protein_id => r[4], :pos => r[2], :terminusmodification => nmod )
      #   nterm.evidences << @evidence
      # }
      
    end # end of OK if
    
    if not ok
      outputFile << "Abortet due to error!!! \n"
    end
    
    outputFile.close

  end
end