namespace :ensembl do


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
  task :ntermini, [:enter2db] do |t, args|
    require "#{RAILS_ROOT}/config/environment"
    
    date = Time.new.strftime("%Y_%m_%d")
    File.new("databases/Ensembl/#{date}_logs.txt", "w").close
    
    species = Species.all
    species.each{|s|
      p "\n #{s.id}"
      species_call_args = {:species_id => s.id, :enter2db => args[:enter2db]}
      Rake::Task["ensembl:ntermini_species"].execute(args=species_call_args)
    }
  end


  # SPECIES SPECIFIC UPDATE TASK
  #
  #
  #
  desc "add n-termini for all ensembl transcripts by species"
  task :ntermini_species, [:species_id, :enter2db] do |t, args|

    enter2db = args[:enter2db] || "f"
    enter2db == "t" ? enter2db = true : enter2db = false
    
    p "Not adding entries to TopFIND DB because 2nd argument (enter2db) was not 't' but '#{args[:enter2db]}'"  if not enter2db 

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
      f << speciesName + " - TopFIND: IDs: " + genes.length.to_s + ", ENSG-Id pairs: #{l.to_s} \n"
    end

    p "TopFIND query done"

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
      f << speciesName + " - Ensembl file read. Intersection with TopFIND: ENSGs: #{fasta.keys.length.to_s} , ENSPs #{l.to_s} \n"
    end

    p "Ensembl file done"



    #####
    ##### MAP ENSEMBL TO TOPFIND AND ADD N-TERMINI
    #####
    seqCutoff = 20
    f << "Sequence Cutoff length is #{seqCutoff} \n"
    if ok    
      nters = []
      cters = []
      nmap2isoforms = {}
      cmap2isoforms = {}
      
      errorFile = File.new(Time.new.strftime("databases/Ensembl/%Y_%m_%d_errors.txt"), "a")
      missedNTer = 0
      missedCTer = 0
      multipleNTer = 0
      multipleCTer = 0
      
      ## map protein sequence to original sequence
      p "#{fasta.keys.length} to process"
      fasta.keys.each_with_index{|ensg, ind|
        if ind % 100 == 0
          print "."
        end
        if ind % 1000 == 0
          print " "
        end
        fasta[ensg].each{|p|
          ensp = p[0]
          seq = p[1] 
          seq.gsub(/X/, '\w') ## TODO  should i remove the "X" and replace it with wildcard?
          if seq.length >= seqCutoff
            genes[ensg].each{|topf|
              fullSeq = topf[0]

              ### N - TERMINI
              current_seq = seq[0,seqCutoff] ##### CUTOFF - CHECK TODO
              nterHits = fullSeq.scan(/#{current_seq}/).length ## how many matches?
              case nterHits
              when 1 
                pos =  fullSeq.index(/#{current_seq}/)
                if not pos.nil? and not pos == 0
                  nters << [ensg, ensp, pos, topf[1], topf[2]] # THIS IS WHERE I COULD ADD THE Met removal (TODO)
                end
              when 0
                errorFile << "  N #{ensp} #{ensg} #{topf[2]}...... not matched - ignored \n"
                missedNTer = missedNTer + 1
                nmap2isoforms.has_key?(ensg) ? nmap2isoforms[ensg] << p : nmap2isoforms[ensg] = [p]
              else
                errorFile << "  N #{ensp} #{ensg} #{topf[2]}...... mapped #{nterHits} times - ignored \n"
                multipleNTer = multipleNTer + 1
              end
            
              ### C - TERMINI
              current_seq = seq[seq.length-seqCutoff, seq.length]
              cterHits = fullSeq.scan(/#{current_seq}/).length ## how many matches?
              case cterHits
              when 1 
                pos =  (fullSeq.index(/#{current_seq}/) + current_seq.length)
                if not pos.nil? and not pos == fullSeq.length
                  cters << [ensg, ensp, pos, topf[1], topf[2]]
                end
              when 0
                errorFile << "  C #{ensp} #{ensg} #{topf[2]}...... not matched - ignored \n"
                missedCTer = missedCTer + 1
                cmap2isoforms.has_key?(ensg) ? cmap2isoforms[ensg] << p : cmap2isoforms[ensg] = [p]
              else
                errorFile << "  C #{ensp} #{ensg} #{topf[2]}...... mapped #{cterHits} times - ignored \n"
                multipleCTer = multipleCTer + 1
              end
            }
          end
        }
      }
      p ""
      errorFile.close
      
      f << "#{nters.length} N-termini found \n"
      f << "#{nters.collect{|t| "#{t[4]}_#{t[2]}"}.uniq.length} unique N-termini will be added\n"
      
      f << "#{cters.length} C-termini found \n"
      f << "#{cters.collect{|t| "#{t[4]}_#{t[2]}"}.uniq.length} unique C-termini will be added\n"
      
      f << "N-termini matches missed: #{missedNTer} multiple: #{multipleNTer} \n"
      f << "C-termini matches missed: #{missedCTer} multiple: #{multipleCTer} \n"
      
      # MAP TO ISOFORMS
      # nter_iso_args = {:entries => nmap2isoforms, :species_id => speciesId, :file => f, :seqCutoff => seqCutoff}
      # Rake::Task["ensembl:isoform_ntermini"].execute(args=nter_iso_args)
      
      if enter2db
        ###
        ### PUT INFO INTO DATABASE
        ###
        evidencecodes = Evidencecode.code_is('ECO:0000203').first
        evidencesource = Evidencesource.find_or_create_by_dbname(
        :dbname => 'Ensembl',
        :dburl => 'http://www.ensembl.org',
        :dbdesc => 'Ensembl'
        )
        p "adding #{nters.length} n-termini"
              
        ## safe N-TERMINI in the database 
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
          @evidence.evidencecodes << evidencecodes
          @evidence.evidencesource = evidencesource
          @evidence.save
          # find or create N-terminus
          nmod = Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  # 
          nterm = Nterm.find_or_create_by_idstring(:idstring => "#{r[4]}-#{(r[2]+1).to_s}-#{nmod.name}",:protein_id => r[3], :pos => r[2]+1, :terminusmodification => nmod )
          nterm.evidences << @evidence
        }
      
        p "adding #{cters.length} c-termini"
      
        ## safe C-TERMINI in the database
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
          @evidence.evidencecodes << evidencecodes
          @evidence.evidencesource = evidencesource
          @evidence.save
          # find or create N-terminus
          nmod = Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  # 
          nterm = Cterm.find_or_create_by_idstring(:idstring => "#{r[4]}-#{(r[2]).to_s}-#{nmod.name}",:protein_id => r[3], :pos => r[2], :terminusmodification => nmod )
          nterm.evidences << @evidence
        }
      end
    end # end of OK if
    
    f << "#{Time.now}\n"
    
    if not ok
      f << "Aborted \n"
    end
    f.close
  end


  # Map to isoform N-termini TASK
  #
  # => requires a particular hash passed to it
  #
  task :isoform_ntermini, [:entries, :species_id, :file, :seqCutoff] do |t, args|
    
    require "#{RAILS_ROOT}/config/environment"
    
    speciesId = args[:species_id]
    f = args[:file]
    seqCutoff = args[:seqCutoff]
    
    #####
    ##### MAKE ENTRIES UNIQUE AND COUNT THEM
    #####
    entries2 = args[:entries] || {}
    entries = {}
    c = 0
    entries2.keys.each{|k|
      entries[k] = entries2[k].uniq
      c = c + entries[k].length
    }
    p " isoforms: mapping #{c} unique missed entries to isoform N-termini"
    f << "#{c} unique entries were not mapped to N-termini \n"
    
    #####
    ##### GET TOPFIND isoform, ensg AND SEQUENCE INFO
    #####   
    g_query = "select distinct d.protein_id, d.content2, i.sequence, i.ac, p.ac from drs d, proteins p, isoforms i where d.db_name = 'Ensembl' and p.id = i.protein_id and d.protein_id = i.protein_id and p.species_id = #{speciesId};"
    g_result =  ActiveRecord::Base.connection.execute(g_query);
    isoforms = {}
    g_result.each{|x|
      # if not x[2].nil? | x[1].nil?
        dat = {"id" => x[0], "seq" => x[2], "iac" => x[3], "ac" => x[4]}
        isoforms.has_key?(x[1]) ? isoforms[x[1]] << dat : isoforms[x[1]] = [dat] 
      # end
    }
    l = 0
    isoforms.each_value{|v|
      l = l + v.length
    }
    f << " TopFIND query for isoforms: retrieved Isoforms: #{isoforms.length} ENSG-Isoform pairs: #{l.to_s} \n"
    p "TopFIND isoform query done"
    
    
    #####
    ##### MAP ENTRIES TO TOPFIND ISOFORMS
    #####
    entries.delete_if{|k, v| !isoforms.has_key?(k) }
    matched = 0
    nter2add = 0
    entries.keys.each_with_index{|ensg, ind|
      ind % 100 == 0 ? print(".") : nil
      ind % 1000 == 0 ? print(" ") : nil
      entries[ensg].each{|p|
        ensp = p[0]
        seq = p[1] 
        seq.gsub(/X/, '\w') ## TODO Maybe here i should remove the "X" and replace it with wildcard?
        matchFound = false
        if seq.length >= seqCutoff
          isoforms[ensg].each{|iso|
            fullSeq = iso["seq"]
            current_seq = seq[0,seqCutoff] ##### CUTOFF - CHECK TODO
            nterHits = fullSeq.scan(/#{current_seq}/).length ## how many matches?
            if nterHits == 1 
              matchFound = true
              if fullSeq.index(/#{current_seq}/) > 0
                nter2add += 1
              end
            end
          }
        end
        matchFound ? matched = matched + 1 : nil
      }
    }
    p ""
    f << " isoforms: #{matched} unique unmatched entries could be matched to >= 1 isoform(s) adding #{nter2add} ntermini \n"
    p "matching done"
  end
end

