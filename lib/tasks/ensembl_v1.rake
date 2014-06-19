namespace :ensembl_v1 do


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
  desc "go through organisms and add N-termini for each from ensembl"
  task :ntermini do
    require "#{RAILS_ROOT}/config/environment"
    
    date = Time.new.strftime("%Y_%m_%d")
    File.new("databases/Ensembl/#{date}_logs.txt", "w").close
    
    species = Species.all
    species.each{|s|
      p s.id
      Rake::Task["ensembl:ntermini_species"].execute(:species_id => s.id)
    }
    
  end


  # SPECIES SPECIFIC UPDATE TASK
  #
  #
  #
  desc "add n-termini for all ensembl transcripts by species"
  task :ntermini_species, :species_id do |t, args|

    require "#{RAILS_ROOT}/config/environment"

    require "bio"

    ok = true

    speciesId = args[:species_id]
    speciesName = Species.find(speciesId).name
    
    f = File.open(Time.new.strftime("databases/Ensembl/%Y_%m_%d_logs.txt"), "a")
    
    f << "\nProcessing " + speciesName + " ID: " + speciesId.to_s + "\n"
    f << "#{Time.now}\n"
    
    #####
    ##### SEE IF FASTA FILES ARE THERE
    #####
    if ok
      case speciesName
      when "Homo sapiens"
        file = Bio::FastaFormat.open("#{RAILS_ROOT}/databases/Ensembl/Homo_sapiens.GRCh37.75.pep.all.fa")
        ensgCode = "ENSG"
        enspCode = "ENSP"
      when "Mus musculus"
        file = Bio::FastaFormat.open("#{RAILS_ROOT}/databases/Ensembl/Mus_musculus.GRCm38.75.pep.all.fa")
        ensgCode = "ENSMUSG"
        enspCode = "ENSMUSP"
        
      else
        f << "Species #{speciesName}, #{speciesId} cannot be processed \n"
        ok = false
      end
    end
  
    #####
    ##### GET TOPFIND ENSG AND SEQUENCE INFO
    #####   
    if ok
      g_query = "select distinct d.protein_id, d.content2, p.sequence, p.ac from drs d, proteins p where d.db_name = 'Ensembl' and p.id = d.protein_id and p.species_id = #{speciesId};"
      g_result =  ActiveRecord::Base.connection.execute(g_query);
      genes = {}
      g_result.each{|x|
        if not genes.has_key?(x[1])
          genes[x[1]] = []
        end
        genes[x[1]] << [x[2], x[0], x[3]] ## can have multiple proteins per ensg?!
      }
      l = 0
      genes.each_value{|v|
        l = l + v.length
      }
      f << speciesName + " - TopFIND: ENSGs: " + genes.length.to_s + ", entries (ENSG-Id pairs): #{l.to_s} \n"
    end

    p "TopFIND done"

    #####
    ##### PARSE ENSEMBL FASTA FILES
    #####
    if ok
      fasta = {}
      file.each do |entry|
        ensp = entry.identifiers().entry_id
        ensg = entry.identifiers().to_s[/.*gene:(#{ensgCode}\d+[^ ]) /,1]
        biotype = entry.identifiers().to_s[/ transcript_biotype:([^\s]+)/,1]
        seq = entry.seq()
        # test that the entry is ok and add entry
        if ensg.nil? or ensp.nil? or seq.nil? or biotype.nil? or not ensp[0,4] == enspCode[0,4]
          p ensp.to_s +  "  " + ensg.to_s + "...FAILED"
          next
        else 
          if biotype == "protein_coding"
            if not fasta.has_key?(ensg)
              fasta[ensg] = []
            end
            fasta[ensg] << [ensp, seq]
          end
        end
      end
      rm = fasta.keys - genes.keys
      rm.each{|k|
        fasta.delete(k)
      }
      l = 0
      fasta.each_value{|v|
        l = l + v.length
      }
      f << speciesName + " - Ensembl from TopFIND: ENSGs: #{fasta.keys.length.to_s} , ENSPs #{l.to_s} \n"
    end

    p "Ensembl done"

    #####
    ##### MAP ENSEMBL TO TOPFIND AND ADD N-TERMINI
    #####
    if ok    
      nters = []
      cters = []
      ## map protein sequence to original sequence
      p "#{fasta.keys.length} to process"
      fasta.keys.each_with_index{|ensg, ind|
        print "."
        if ind % 100 == 0
          print " "
        end
        if ind % 1000 == 0
          print "\n"
        end
        p ensg
        fasta[ensg].each{|p|
          ensp = p[0]
          seq = p[1] 
          seq.gsub(/X/, '\w') ## TODO Maybe here i should remove the "X" and replace it with wildcard?
          genes[ensg].each{|topf|
            fullSeq = topf[0]


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
                  nters << [ensg, ensp, pos, topf[1], topf[2]]
                end
                break
              when 0
                sl = sl - 1
                next
              else
                f << "  #{ensp} #{ensg}...... mapped more than once - ignored \n"
                break
              end
            end
            
            ### C - TERMINI
            # sstart is the start position. This loop goes up the sequence from the front and tries to map it to the full sequence
            sstart = 0
            current_seq = seq
            while(true) do
              if current_seq.length < 20 ##### CUTOFF - CHECK TODO
                break 
              end
              current_seq = seq[sstart, seq.length]
              case fullSeq.scan(/#{current_seq}/).length ## how many matches?
              when 1 
                pos =  (fullSeq.index(/#{current_seq}/) + current_seq.length)
                if not pos.nil? and not pos == fullSeq.length
                  cters << [ensg, ensp, pos, topf[1], topf[2]]
                end
                break
              when 0
                sstart = sstart + 1
                next
              else
                f << "  #{ensp} #{ensg}...... mapped more than once - ignored \n"
                break
              end
            end
          }
        }
      }
      
      f << "#{nters.length} N-termini found \n"
      f << "#{cters.length} C-termini found \n"
      
      p "adding #{nters.length} n-termini"

      # safe N-TERMINI in the database 
      nters.each{|r| 
        #p ("nter - " + r[0] + "  " + r[1].to_s + "  " +  r[2].to_s + "  " + r[3].to_s + " " + r[4])
        # find or create evidence
        @evidence = Evidence.find_or_create_by_name(:name => "inferred from ensembl protein #{r[1]}",
          :idstring => "ensembl-#{r[1]}-ECO:0000203",
          :description => 'The stated informations has been extracted from the Ensembl database.',
          :phys_relevance => 'unknown',
          :method => 'electronic annotation',
          :repository => "http://ensembl.org/#{speciesName.gsub(/ /,"_")}/Transcript/Summary?db=core;g=#{r[0]};p=#{r[1]}"
        )
        @evidence.evidencecodes << Evidencecode.code_is('ECO:0000203').first
        @evidence.evidencesource = Evidencesource.find_or_create_by_dbname(
          :dbname => 'Ensembl',
          :dburl => 'http://www.ensembl.org',
          :dbdesc => 'Ensembl'
        )
        @evidence.save
        # find or create N-terminus
        nmod = Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  # 
        nterm = Nterm.find_or_create_by_idstring(:idstring => "#{r[4]}-#{(r[2]+1).to_s}-#{nmod.name}",:protein_id => r[3], :pos => r[2]+1, :terminusmodification => nmod )
        nterm.evidences << @evidence
      }
      
      p "adding #{cters.length} c-termini"
      
      # safe C-TERMINI in the database
      cters.each{|r| 
        #p ("cter - " + r[0] + "  " + r[1].to_s + "  " +  r[2].to_s + "  " + r[3].to_s + " " + r[4])
        # find or create evidence
        @evidence = Evidence.find_or_create_by_name(:name => "inferred from ensembl protein #{r[1]}",
          :idstring => "ensembl-#{r[1]}-ECO:0000203",
          :description => 'The stated informations has been extracted from the Ensembl database.',
          :phys_relevance => 'unknown',
          :method => 'electronic annotation',
          :repository => "http://ensembl.org/#{speciesName.gsub(/ /,"_")}/Transcript/Summary?db=core;g=#{r[0]};p=#{r[1]}"
        )
        @evidence.evidencecodes << Evidencecode.code_is('ECO:0000203').first
        @evidence.evidencesource = Evidencesource.find_or_create_by_dbname(
          :dbname => 'Ensembl',
          :dburl => 'http://www.ensembl.org',
          :dbdesc => 'Ensembl'
        )
        @evidence.save
        # find or create N-terminus
        nmod = Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  # 
        nterm = Cterm.find_or_create_by_idstring(:idstring => "#{r[4]}-#{(r[2]).to_s}-#{nmod.name}",:protein_id => r[3], :pos => r[2], :terminusmodification => nmod )
        nterm.evidences << @evidence
      }
      
    end # end of OK if
    
    f << "#{Time.now}\n"
    
    if not ok
      f << "Abortet due to error!!! \n"
    end
    f.close
  end

end

