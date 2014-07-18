desc "import data"
task :import_uniprot do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  require 'biomart'
  
  Biomart.timeout = 1800   
  biomart = Biomart::Server.new( "http://www.biomart.org/biomart" )  
  puts "biomart connected"
  case ARGV[1]
    when 'human' 
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot/uniprot_sprot_human.dat.gz")
      io = File.open("#{RAILS_ROOT}/source_data/uniprot_2014-06/uniprot-%28organism%3A9606+keyword%3A1185%29+AND+reviewed%3Ayes.txt")
      @mart = biomart.datasets["hsapiens_gene_ensembl"]
    when 'mouse'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_rodents.dat.gz")
      io = File.open("#{RAILS_ROOT}/source_data/uniprot_2014-06/uniprot-%28organism%3A10090+keyword%3A1185%29+AND+reviewed%3Ayes.txt") 
      @mart = biomart.datasets["mmusculus_gene_ensembl"] 
    when 'arabidopsis'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_plants.dat.gz")
      io = File.open("#{RAILS_ROOT}/source_data/uniprot_2014-06/uniprot-%28organism%3A3702+keyword%3A1185%29+AND+reviewed%3Ayes.txt")
    when 'arabidopsis-trembl'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_trembl_plants.dat.gz")
    when 'ecoli'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/source_data/uniprot_2014-06/uniprot_sprot_bacteria.dat.gz")
      io = File.open("#{RAILS_ROOT}/databases/topfind_update_1305/uniprot-%28organism%3A83333+keyword%3A1185%29+AND+reviewed%3Ayes.txt")
    when 'yeast'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_fungi.dat.gz")
      io = File.open("#{RAILS_ROOT}/source_data/uniprot_2014-06/uniprot-%28organism%3A559292+keyword%3A1185%29+AND+reviewed%3Ayes.txt")
      @mart = biomart.datasets["scerevisiae_gene_ensembl"]
  end
  puts "done"
    
    @skipped = 0
    @added = 0
    @updated = 0
    
    
  #create a Terminusmodifciation of kind 'unknown' to be used as default
  Terminusmodification.find_or_create_by_name(:name => "unknown", :nterm => true, :cterm => true, :display => true)  


  #generate or select "inferred from uniprot" evidence
  @evidence = Evidence.find_or_create_by_name(:name => 'inferred from uniprot',
    :idstring => 'uniprot-ECO:0000203',
    :description => 'The stated informations has been extracted from the UniprotKB database.',
    :phys_relevance => 'unknown',
    :method => 'electronic annotation'
  )
  @evidence.evidencecodes << Evidencecode.code_is('ECO:0000203').first
  @evidence.evidencesource = Evidencesource.find_or_create_by_dbname(
    :dbname => 'UniProtKB',
    :dburl => 'http://www.uniprot.org',
    :dbdesc => 'Uniprot/SWISSprot'
  )
  @evidence.save

  @evidencesimilarity = Evidence.find_or_create_by_name(:name => 'inferred from uniprot (by similarity)',
    :idstring => 'uniprot-ECO:0000041',
    :description => 'The stated informations has been extracted from the UniprotKB database and is based on similarity.',
    :phys_relevance => 'unknown',
    :method => 'electronic annotation'
  )
  @evidencesimilarity.evidencecodes << Evidencecode.code_is('ECO:0000041').first
  @evidencesimilarity.evidencesource = Evidencesource.find_or_create_by_dbname(
    :dbname => 'UniprotKB',
    :dburl => 'http://www.uniprot.org',
    :dbdesc => 'Uniprot/SWISSprot'
  )
  @evidencesimilarity.save

  puts "before file open"
  Bio::FlatFile.open(io).each_with_index do |entry,i|
      skip = ARGV[2]
      if skip.present? && i < skip.to_i 
       puts "#{i} - "
       next
      end 
    
    exit if i == 1000
    
    orgs = entry.os.map {|os| os['os']}

    unless orgs.include?('Homo sapiens') || orgs.include?('Mus musculus') || orgs.include?('Arabidopsis thaliana') || orgs.include?('Escherichia coli')  || orgs.include?('Saccharomyces cerevisiae')    
      @skipped = @skipped.next
      puts "\tskipped - #{@skipped} " 
      next
    else
      $stdout.sync = true
      
  
     
      p = Protein.find_by_ac(entry.accessions[0])

      
      #set update true if we already have a protein with matching accession in the db
      p ? update = true : update = false       
      
      if update && (ARGV[2] == 'noupdate' || ARGV[3] == 'noupdate')
        @updated = @updated.next 
        print "\t not updated - #{@updated} ."
        next
      elsif update 
        @updated = @updated.next 
        print "\t updating - #{@updated} ." 
      else
        @added = @added.next     
        print "\t adding - #{@added} ." 
      end
      if @mart
      	pmart = @mart.search(:filters => {'uniprot_swissprot_accession' => entry.accessions[0]},:attributes => ['chromosome_name','band'])
      	chromosome = pmart[:data].flatten[0] if pmart
      	band = pmart[:data].flatten[1] if pmart
      	print ";"
      end      
    end   


    
    if update 
      p.update_attributes(:name          => entry.id_line['ENTRY_NAME'].to_s,
                  :data_class      => entry.id_line['DATA_CLASS'].to_s,
                  :molecular_type  => entry.id_line['MOLECULE_TYPE'].to_s,
                  :dt_create       => entry.dt['created'].to_s,
                  :dt_sequence     => entry.dt['sequence'].to_s,
                  :dt_annotation   => entry.dt['annotation'].to_s,
                  :definition      => entry.de,
                  :sequence        => entry.seq.to_s,
                  :crc64           => entry.sq['CRC64'].to_s,
                  :mw              => entry.sq['MW'].to_i,
                  :aalen           => entry.sq['aalen'].to_i,
                  :chromosome	   => chromosome,
                  :band            => band,
                  :status          => 'updated')
    else
      p = Protein.create(:id              => entry.entry_id,
                  :ac              => entry.accessions[0],
                  :name          => entry.id_line['ENTRY_NAME'].to_s,
                  :data_class      => entry.id_line['DATA_CLASS'].to_s,
                  :molecular_type  => entry.id_line['MOLECULE_TYPE'].to_s,
                  :dt_create       => entry.dt['created'].to_s,
                  :dt_sequence     => entry.dt['sequence'].to_s,
                  :dt_annotation   => entry.dt['annotation'].to_s,
                  :definition      => entry.de,
                  :sequence        => entry.seq.to_s,
                  :crc64           => entry.sq['CRC64'].to_s,
                  :mw              => entry.sq['MW'].to_i,
                  :aalen           => entry.sq['aalen'].to_i, 
                  :chromosome	   => chromosome,
                  :band            => band,                 
                  :status          => 'created')
    end
    
    p.save
    
    print "."  
    
    # Extract recommendet and alternative names from "de" string
    recnames = entry.de.match(/^RecName: (.*?)( AltName|$)/)
    recname = Hash.new
  
    if recnames 
      recnames[1].match(/Full=.*?;/) ? recname['full'] = recnames[1].match(/Full=(.*?);/)[1] : recname['full'] = ''
      recnames[1].match(/Short=.*?;/) ? recname['short'] = recnames[1].match(/Short=(.*?);/)[1] : recname['short'] = ''
    end
    
    altnames = entry.de.match(/RecName: .*?; AltName:(.*?)( Contains| Flags|$)/)
    if altnames
      altname = Array.new
      altnames[1].split('; ').each do |name|
        name.match(/Full=.*/) ? altname.push({'full' => name.match(/Full=(.*)/)[1]})  : 1
        name.match(/Short=(.*)/) ? altname[altname.length-1].merge!({'short' => name.match(/Short=(.*)/)[1]}) :1
      end
    end     
      

    p.proteinnames << Proteinname.find_or_create_by_full(:full => recname['full'], :short => recname['short'], :recommended => true)
    if altname 
      altname.each do |name|
        temp = Proteinname.find_or_create_by_full(:full => name['full'], :short => recname['short'], :recommended => false)
        p.proteinnames << temp unless p.proteinnames.include?(temp)
      end
    end
    ## add gene symbol name with stripped species as altname (eg 1433B for 1433B_HUMAN)
    temp = Proteinname.find_or_create_by_full(:full => entry.id_line['ENTRY_NAME'].to_s.split('_')[0], :short => '', :recommended => false)
    p.proteinnames << temp unless p.proteinnames.include?(temp)
    print "."




    entry.accessions.each do |ac|
      temp = Ac.find_or_create_by_name(:name => ac)
      p.acs << temp unless p.acs.include?(temp)
    end

    print "."

    unless update
      entry.os.each do |os|
        if s = Species.find_by_name(os['os']) 
        else s = Species.new(:name => os['os'], :common_name => os['name'].to_s)
        end
        p.update_attributes(:species => s )
      end
  
      print "."
  
      entry.oc.each_with_index do |key, level|
        if o = Oc.find_by_name(key)
        else o = Oc.new(:name => key, :level => level)
        end
        temp = o
        p.ocs << temp unless p.ocs.include?(temp)
      end
  
      print "."
  
      entry.ox.each do |db_name, accs|
        accs.each do |acc|
          if o = Ox.find(:first, :conditions => ["db_name = ? AND accession = ?", 
                                                 db_name, acc])
          else o = Ox.new(:db_name => db_name, :accession => acc)
          end
        temp = o
        p.oxs << temp unless p.oxs.include?(temp)
        end
      end
  
      p.gn = Gn.new
      entry.gn.each do |g|
        unless g.class == Hash
          cannonical_key = {'ORFNames' => :orfs, 'Name' => :name, 
                            'OrderedLocusNames' => :loci}
          g2 = {}
          g.to_s.split(';').map {|x| x.strip }.each do |ge|
            key, value = ge.split('=')
            g2[cannonical_key[key]] = value
          end
          g = g2
        end
        g[:synonyms] = [] unless g[:synonyms]
        g[:name] = '' unless g[:name]
        g[:loci] = [] unless g[:loci]
        g[:orfs] = [] unless g[:orfs]
        p.gn.name = g[:name]
  
        g[:synonyms].map do |synonym|
          temp = GnSynonym.find_or_create_by_synonym(:synonym => synonym)
          p.gn.synonyms << temp unless p.gn.synonyms.include?(temp)
        end
        g[:loci].each do |locus|
          temp = GnLocus.find_or_create_by_locus(:locus => locus)
          p.gn.loci << temp unless p.gn.loci.include?(temp)
        end
        g[:orfs].map do |orf|
          temp = GnOrfName.find_or_create_by_name(:name => orf)
          p.gn.orf_names << temp unless p.gn.orf_names.include?(temp)
        end
      end
  
      print "."
  
      entry.ref.each do |ref|
        r = Ref.new(:title => ref['RT'],
                    :auther => ref['RA'],
                    :location => ref['RL'])
      print "."
        ref['RG'].each do |rg|
          r.rgs << Rg.find_or_create_by_name(:name => rg)
        end
      print "."
        ref['RX'].each do |key, value|
          next if value == nil
          r.rxs << Rx.new(:name => key, :identifier => value)
          # key == 'PubMed' ? p.publications.create(:pmid => value) : 1
        end
      print "."
        ref['RP'].each do |rp|
          r.rps << Rp.find_or_create_by_comment(:comment => rp)
        end
      print "."
        ref['RC'].each do |rc|
          r.rcs << Rc.new(:token => rc['Token'], :text => rc['Text'])
        end
        p.refs << r
      end
  
      print "."
  
      entry.cc.each do |k, v|

        [entry.cc(k)].flatten.each do |value|
          temp = Cc.new(:topic => k, 
                          :contents => value) 
        end


      end
  
      print "."
  
      entry.dr.each do |db_name, vs|
        vs.each do |v|
          p.drs << Dr.new(:db_name   => db_name, 
                          :protein_name => v[0], 
                          :content1   => v[1].to_s, 
                          :content2   => v[2].to_s, 
                          :content3   => v[3].to_s)
        end
      end
  
      print "."
    end # unless update  

    entry.kw.each do |key|
      if kw = Kw.find_by_name(key)
      else kw = Kw.find_or_create_by_name(:name => key) 
      end
      temp = kw
      p.kws << temp unless p.kws.include(temp)
    end

    tempfts = Array.new
    entry.ft.each do |name, fts|
      fts.each do |ft|
        tempfts << Ft.new(:name => name,
                        :from => ft['From'],
                        :to => ft['To'],
                        :description => ft['Description'],
                        :ftid => ft['FTId'])                
        #add chains
        if name == 'CHAIN'
          chain = p.chains.find_or_create_by_idstring(
                                  :idstring => "#{p.ac}_#{ft['From']}-#{ft['To']}",
          						            :name => ft['Description'],
                                  :protein_id => p.id,
                                  :from => ft['From'],
                                  :to => ft['To'])
                      
          chain.evidences << @evidence unless chain.evidences.include?(@evidence)
        end                                          
      end
    end
    p.fts.*.destroy
    tempfts.map { |f| p.fts << f}

    print "."
    
    p.chains.each do |chain|
    	#cterms    
    	  cterm = chain.cterm
    	  unless cterm
	          cft = p.fts.matchfrom(chain.to).name_is('MOD_RES').first if p.fts.matchfrom(chain.to).present?
	          cft ? cmodname = cft.description.delete('.').split(';')[0] : cmodname = 'unknown'
	          cmod = Terminusmodification.cterm_is(true).name_is(cmodname).first
      		  cmod = Terminusmodification.name_is('unknown').first if cmod.blank?    	  	 
	          cterm = Cterm.find_or_create_by_idstring(:idstring => "#{p.ac}-#{chain.to}-#{cmod.name}",:protein_id => p.id, :pos => chain.to, :terminusmodification => cmod )
	          cterm.evidences << @evidence unless cterm.evidences.include?(@evidence)
	          p.cterms << cterm	unless p.cterms.include?(cterm)
    	  end
    	  
    	#nterms    
   	  	  nterm = chain.nterm
    	  unless nterm
	          nft = p.fts.matchfrom(chain.from).name_is('MOD_RES').first if p.fts.matchfrom(chain.from).present?
	          nft ? nmodname = nft.description.delete('.').split(';')[0] : nmodname = 'unknown'
              nmodname = 'acetylation' if nmodname.include?('acetyl')
	          nmod = Terminusmodification.nterm_is(true).name_is(nmodname).first
            nmod = Terminusmodification.name_is('unknown').first if nmod.blank?    	  	 
	          nterm = Nterm.find_or_create_by_idstring(:idstring => "#{p.ac}-#{chain.from}-#{nmod.name}",:protein_id => p.id, :pos => chain.from, :terminusmodification => nmod )
	          nterm.evidences << @evidence unless nterm.evidences.include?(@evidence)
	          p.nterms << nterm	unless p.nterms.include?(nterm)
    	  end
    	  chain.update_attributes(:cterm_id => cterm.id, :nterm_id => nterm.id)	
    end
    
    #create N-Terminus for methionine removed
    p.fts.name_is('INIT_MET').each do |ft|
      nft = p.fts.matchfrom(ft.from).name_is('MOD_RES').first
      nft ? nmodname = nft.description.delete('.').split(';')[0] : nmodname = 'unknown'
      nmodname = 'acetylation' if nmodname.include?('acetyl')
      nmod = Terminusmodification.nterm_is(true).name_is(nmodname).first  
      nmod = Terminusmodification.name_is('unknown').first if nmod.blank?  	  	 
      nterm = Nterm.find_or_create_by_idstring(:idstring => "#{p.ac}-2-#{nmod.name}",:protein_id => p.id, :pos => ft.from, :terminusmodification => nmod )
      
      if ft.description.include?('similarity')
      	nterm.evidences << @evidencesimilarity unless nterm.evidences.include?(@evidencesimilarity)
      else 
      	nterm.evidences << @evidence unless nterm.evidences.include?(@evidence)
      end
      p.nterms << nterm	unless p.nterms.include?(nterm)
      print ','    	
    end
    
    #create N-terminus for signal peptides
    ftids = p.fts.description_in(['Potential.','By similarity.','Probable.']).*.id
    ftids = ftids & p.fts.name_is('SIGNAL').*.id
    ftids = nil if ftids.blank?
    p.fts.id_in(ftids).each do |ft|
      nft = p.fts.matchfrom(ft.to.to_i+1).name_is('MOD_RES').first
      nft ? nmodname = nft.description.delete('.').split(';')[0] : nmodname = 'unknown'
      nmodname = 'acetylation' if nmodname.include?('acetyl')
      nmod = Terminusmodification.nterm_is(true).name_is(nmodname).first 
      nmod = Terminusmodification.name_is('unknown').first if nmod.blank?   	  	 
      nterm = Nterm.find_or_create_by_idstring(:idstring => "#{p.ac}-#{ft.to.to_i+1}-#{nmod.name}",:protein_id => p.id, :pos => ft.to.to_i+1, :terminusmodification => nmod )
      nterm.evidences << @evidence unless nterm.evidences.include?(@evidence)
      if ft.description.include?('similarity')
      	nterm.evidences << @evidencesimilarity unless nterm.evidences.include?(@evidencesimilarity)
      else 
      	nterm.evidences << @evidence unless nterm.evidences.include?(@evidence)
      end
      p.nterms << nterm unless p.nterms.include?(nterm)
      print ','        	
    end

    #create N-terminus for pro-peptides
    p.fts.description_like('Removed').name_is('SIGNAL').each do |ft|
      nft = p.fts.matchfrom(ft.to.to_i+1).name_is('MOD_RES').first
      nft ? nmodname = nft.description.delete('.').split(';')[0] : nmodname = 'unknown'
      nmodname = 'acetylation' if nmodname.include?('acetyl')
      nmod = Terminusmodification.nterm_is(true).name_is(nmodname).first
      nmod = Terminusmodification.name_is('unknown').first if nmod.blank?    	  	 
      nterm = Nterm.find_or_create_by_idstring(:idstring => "#{p.ac}-#{ft.to.to_i+1}-#{nmod.name}",:protein_id => p.id, :pos => ft.to.to_i+1, :terminusmodification => nmod )
      nterm.evidences << @evidence
      if ft.description.include?('similarity')
      	nterm.evidences << @evidencesimilarity unless nterm.evidences.include?(@evidencesimilarity)
      else 
      	nterm.evidences << @evidence unless nterm.evidences.include?(@evidence)
      end
      p.nterms << nterm	unless p.nterms.include?(nterm)	
      print ','        	
    end    	

    #create C-terminus for Cterminal pro-peptides
    p.fts.description_like('C-terminal').name_is('SIGNAL').each do |ft|
      nft = p.fts.matchfrom(ft.from.to_i-1).name_is('MOD_RES').first
      nft ? nmodname = nft.description.delete('.').split(';')[0] : nmodname = 'unknown'
      nmod = Terminusmodification.cterm_is(true).name_is(nmodname).first
      nmod = Terminusmodification.name_is('unknown').first if nmod.blank?    	  	 
      cterm = Cterm.find_or_create_by_idstring(:idstring => "#{p.ac}-#{ft.from.to_i-1}-#{nmod.name}",:protein_id => p.id, :pos => ft.from.to_i-1, :terminusmodification => nmod )
      cterm.evidences << @evidence
      if ft.description.include?('similarity')
      	cterm.evidences << @evidencesimilarity unless cterm.evidences.include?(@evidencesimilarity)
      else 
      	cterm.evidences << @evidence  unless cterm.evidences.include?(@evidence)
      end
      p.cterms << cterm	unless p.cterms.include?(cterm)
      print ','        	
    end
    
    print '.'
     
    p.save

    puts 'done'
  end
end


desc "import isofroms for proteins present in db"
task :import_isoforms do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'

  @evidence = Evidence.name_is('inferred from uniprot').first

  Bio::FlatFile.open(ARGV[1]).each_with_index do |entry,i|
    # if i == 1 
    #   break
    # end
    isoform_ac = entry.accessions.first
    isoform_num = entry.accessions.first.split('-')[1]
    fullname = entry.identifiers.description.split(' OS=')[0]
    short_canonical_name = entry.identifiers.sp.split(' ')[0]
    short_isoform_name = short_canonical_name.gsub('_',"-Isoform#{isoform_num}_") 

    canonical_protein_ac = isoform_ac.split('-')[0]  
    canonical_protein = Protein.find_by_ac(canonical_protein_ac)
    @imported = 0
    
    if canonical_protein
      Isoform.find_or_create_by_ac(:protein => canonical_protein, 
                  :ac => entry.accessions.first, 
                  :name => fullname, 
                  :sequence => entry.aaseq)

      isoform = Protein.find_or_create_by_ac(:ac => isoform_ac,
        :name => short_isoform_name, 
    	:sequence => entry.aaseq,
        :aalen => entry.aalen,
        :chromosome => canonical_protein.chromosome,
        :band => canonical_protein.band,
        :species_id => canonical_protein.species_id)
      
      if canonical_protein.drs.db_name_is('Ensembl').present?  
        isoform.drs << Dr.new(:db_name   => 'Ensembl', 
                          :protein_name => '', 
                          :content1   => '', 
                          :content2   => canonical_protein.drs.db_name_is('Ensembl').first.content2, 
                          :content3   => '')
        end	

      isoform.proteinnames << Proteinname.find_or_create_by_full(:full => fullname, :short => short_isoform_name, :recommended => true)
      
	  #add N and C termin for sequence start and end
    	#Cterm
    	cmod = Terminusmodification.name_is('unknown').first    	  	 
		cterm = Cterm.find_or_create_by_idstring(:idstring => "#{isoform.ac}-#{entry.aalen}-#{cmod.name}",:protein_id => isoform.id, :pos => entry.aalen, :terminusmodification => cmod )
	    cterm.evidences << @evidence unless cterm.evidences.include?(@evidence)
	    isoform.cterms << cterm	unless isoform.cterms.include?(cterm)
	    
		#Nterm
    	nmod = Terminusmodification.name_is('unknown').first    	  	 
		nterm = Nterm.find_or_create_by_idstring(:idstring => "#{isoform.ac}-1-#{nmod.name}",:protein_id => isoform.id, :pos => 1, :terminusmodification => nmod )
	    nterm.evidences << @evidence unless nterm.evidences.include?(@evidence)
	    isoform.nterms << nterm	unless isoform.nterms.include?(nterm)
    	  
        
      @imported = @imported.next
    end

    puts "Imported #{@imported} Isoforms"
  end
end


desc "cross map termini between isoforms"
task :cross_map_termini do
  require "#{RAILS_ROOT}/config/environment"
  
  Nterm.all.each do |n|
    n.map_to_isoforms
  end
  Cterm.all.each do |c|
    c.map_to_isoforms
  end
end

desc "delete all uniprot data"
task :prune_uniprot do
  require "#{RAILS_ROOT}/config/environment"
  
  #delete all information from uniprot except for the main protein entry
  
  ActiveRecord::Base.connection.execute('TRUNCATE acs')
  ActiveRecord::Base.connection.execute('TRUNCATE drs')
  ActiveRecord::Base.connection.execute('TRUNCATE fts')
  ActiveRecord::Base.connection.execute('TRUNCATE gns')
  ActiveRecord::Base.connection.execute('TRUNCATE gn_loci')
  ActiveRecord::Base.connection.execute('TRUNCATE gn_orf_names')
  ActiveRecord::Base.connection.execute('TRUNCATE gn_synonyms')
  ActiveRecord::Base.connection.execute('TRUNCATE kws')
  ActiveRecord::Base.connection.execute('TRUNCATE kws_proteins')
  ActiveRecord::Base.connection.execute('TRUNCATE ocs')
  ActiveRecord::Base.connection.execute('TRUNCATE ocs_proteins')
  ActiveRecord::Base.connection.execute('TRUNCATE oss')
  ActiveRecord::Base.connection.execute('TRUNCATE oss_proteins')
  ActiveRecord::Base.connection.execute('TRUNCATE oxs')
  ActiveRecord::Base.connection.execute('TRUNCATE oxs_proteins')
  ActiveRecord::Base.connection.execute('TRUNCATE proteinnames')
  ActiveRecord::Base.connection.execute('TRUNCATE rcs')
  ActiveRecord::Base.connection.execute('TRUNCATE refs')
  ActiveRecord::Base.connection.execute('TRUNCATE rgs')
  ActiveRecord::Base.connection.execute('TRUNCATE rps')
  ActiveRecord::Base.connection.execute('TRUNCATE rxs')
  
  # Chain.evidences_name_is('inferred_from_uniprot').*.destroy
  # Nterm.evidences_name_is('inferred_from_uniprot').*.destroy
  # Cterm.evidences_name_is('inferred_from_uniprot').*.destroy
  
  #mark all protein and isofrom entries as pruned
  Protein.update_all(:status => 'pruned')
  Isoform.update_all(:status => 'pruned')
end






desc "import tissues from uniprot"
task :import_tislist do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/ontologies/uniprot/tislist.dat.gz")
  filename = "#{RAILS_ROOT}/source_data/tisslist.txt"
    @skipped = 0
    @added = 0

  a = Bio::FlatFile.open(Bio::SPTR,filename)
  a.each do |e|
   tsid = e.get('ID').delete('ID    ').delete('.')
   ac = e.get('AC').delete('AC    ').delete('.')
   sy = e.get('SY').delete('SY    ').delete('.').split(';')
   t = Tissue.new(:tsid              => tsid,
                  :ac              => ac)
   t.save
   sy.each do |s|
     ts = t.tissuesynonymes.new(:sy => s)
     ts.save
   end
                   
  end
end  
  
desc "import terminal modifications from ptmlist.txt"
task :import_ptmlist do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  filename = "#{RAILS_ROOT}/source_data/ptmlist.txt"
    @skipped = 0
    @added = 0
	

   kws={'cterm' => [],'nterm'=> [],'anywhere'=>[]}
   fts={'cterm' => [],'nterm'=> [],'anywhere'=>[]}
  mods = Hash.new
  
  a = Bio::FlatFile.open(Bio::SPTR,filename)
  a.each do |e|
   cterm = false
   nterm = false
   f = ''
   anywhere = false  	
   pp = e.get('PP')
   f = e.get('FT').gsub(/FT   /,'').delete('.').chomp   
   cterm = true if pp.include?('C-terminal')
   nterm = true if pp.include?('N-terminal')
   anywhere = true if pp.include?('Anywhere')
   
   cterm || nterm ? display = true : display = false
   
   if (cterm || nterm || anywhere) && f == 'MOD_RES' 
       @added +=1
	   id = e.get('ID').gsub(/ID   /,'').delete('.').chomp
	   ac = e.get('AC').gsub(/AC   /,'').delete('.').chomp
	   ft = e.get('FT').gsub(/FT   /,'').delete('.').chomp 	   
	   lc = e.get('LC').gsub(/LC   /,'').delete('.').chomp
	   kws = e.get('KW').gsub(/KW   /,'').gsub(/(; |;\n)/,';').delete('.').chomp.split(';')
	   drs = Hash.new
	   e.get('DR').gsub(/DR   /,'').map {|r| dr = r.delete(' ').chomp.split(';'); drs[dr[0]]=dr[1].delete('.')} 
	   psimod = "MOD:#{drs['PSI-MOD']}"

	   # create top level entry for each keyword
	   kws.each do |kw|
	   	tkw = Terminusmodification.find_or_create_by_name(:name => kw,:nterm => nterm, :cterm => cterm, :subcell => lc, :display => display)
	   	tkw.kw = Kw.find_by_name(kw)
	   	tkw.save
	   end
	   tm = Terminusmodification.find_or_create_by_ac(:ac => ac, :display => display)
	   tm.update_attributes(:name => id, :nterm => nterm, :cterm => cterm, :subcell => lc, :psimodid => psimod)
	   tm.kw = Kw.find_by_name(kws.first)
	   tm.save

	   puts "#{@added}:#{id}-#{nterm}-#{cterm}-#{ac}-#{lc}-#{kws.join('||')}-#{psimod}"
   end 
   Terminusmodification.find_or_create_by_name(:name => 'unknown', :ac => '', :display => true, :cterm => true,:nterm => true, :kw => Kw.name_is('unknown').first)   
		         
  end    
end 


desc "import keyword definitions from keywlist.txt"
task :import_keywlist do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  filename = "#{RAILS_ROOT}/source_data/keywlist.txt"
    @skipped = 0
    @added = 0
		   
  mods = Hash.new
  
  a = Bio::FlatFile.open(Bio::SPTR,filename)
  a.each do |e|
  	     
       @added +=1
	   id = e.get('ID').gsub(/ID   /,'').delete('.').chomp
	   ac = e.get('AC').gsub(/AC   /,'').delete('.').chomp
	   de = e.get('DE').gsub(/DE   /,'').delete('.').chomp	   
	   sy = e.get('SY').gsub(/SY   /,'').gsub(/(; |;\n)/,';').delete('.').chomp.split(';')
	   ca = e.get('CA').gsub(/CA   /,'').delete('.').chomp
	   
	   
	 unless ac.include?(' ') || ac ==''
	   kw = Kw.find_or_create_by_name(:name => id)
	   kw.update_attributes(:ac => ac, :description => de, :category => ca)
	   kw.save
	   sy.each do |s|
	     kws = kw.kwsynonymes.find_or_create_by_name(:name => s)
	     kws.save
	   end
	   kw.save
	   puts "#{@added}:#{id} and #{sy.count} Synonymes"
	 end
  end
  Kw.find_or_create_by_name(:name => 'unknown')    
end 

desc "import uniprot evidence codes from evidence_code.obo"



task :import_evidencecodes do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'  
  
  filename = "#{RAILS_ROOT}/source_data/evidence_code.obo"
  
  @term = Hash.new
  
  File.open(filename) do |f|
    f.each_line do |l|
      case l
      	when "\n"	
          if @term.key?('id') && @term['name'].chomp != 'evidence_code' && @term['name'].present?
            code = @term['id'].chomp
            name = @term['name'].delete('"').chomp
            @term['def'].present? ? definition = @term['def'].delete('"').chomp : definition = ''
            e = Evidencecode.find_or_create_by_code(:code => code,
              :name => name,
              :definition => definition)
          end
        when "[Term]\n"
          @term = Hash.new
        else
          row = l.split(': ')
          @term[row[0]] = row[1]
      end
    end
  end
end



desc "add terminusmodifications from uniprot based on similarity"
task :add_terminusmodifications do
  require "#{RAILS_ROOT}/config/environment"
  

  
  evidence = Evidence.name_is('inferred from uniprot').first
  newevidence = Evidence.name_is('inferred from uniprot (by similarity)').first
  total = Nterm.evidences_id_is(evidence.id).uniq.count
  count = 0
  updated = 0

  y evidence
  y newevidence
  y total
  
  Nterm.evidences_id_is(evidence.id).uniq.each do |n|	
  	count += 1
  	print "#{count}/#{total}(#{updated}) - "
  	
  	oldmod = n.terminusmodification
  	#only fix unknown inferred from uniprot
  	if oldmod.name == 'unknown' && n.evidences.count == 1
  		ft = n.protein.fts.matchfrom(n.pos).name_is('MOD_RES').first
  		if ft.present?
  			nmodname = ''
	      	match = ft.description.delete('.').match(/(.*)?\ \(By similarity\)/)
	      	nmodname = match[1] if match.present?
	      	print "#{oldmod.name} - #{nmodname} "
	      	nt = Terminusmodification.nterm_is(true).name_is(nmodname).first
	      	if nt
	      		nterm = Nterm.find(n.id)
	      		nterm.update_attributes(:terminusmodification_id => nt.id, :evidences => [newevidence])
	      		print " update #{nterm.id} to: #{nterm.terminusmodification.name} - #{nterm.evidences.*.id.join(',')} "
	      		updated += 1
	      	end
	    end
  	end
    print ".\n"
  	
  end
end

desc "import uniprot names"
task :import_uniprot_names do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
    case ARGV[1]
    when 'human' 
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_human.dat.gz")
      io = File.open("#{RAILS_ROOT}/databases/topfind_update_1305/databases/130521_uniprot_human.dat.txt")
    when 'mouse'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_rodents.dat.gz")
      io = File.open("#{RAILS_ROOT}/databases/topfind_update_1305/databases/130521_uniprot_mouse.dat.txt") 
    when 'arabidopsis'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_plants.dat.gz")
      io = File.open("#{RAILS_ROOT}/databases/topfind_update_1305/databases/130521_uniprot_arabidopsis.dat.txt")
    when 'arabidopsis-trembl'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_trembl_plants.dat.gz")
    when 'ecoli'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_bacteria.dat.gz")
      io = File.open("#{RAILS_ROOT}/databases/topfind_update_1305/databases/130521_uniprot_ecoli.dat.txt")
    when 'yeast'
      # io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_fungi.dat.gz")
      io = File.open("#{RAILS_ROOT}/databases/topfind_update_1305/databases/130521_uniprot_yeast.dat.txt")  end
  puts "done"
    
    @skipped = 0
    @added = 0
    @updated = 0
    
    
  puts "before file open"
  Bio::FlatFile.open(io).each_with_index do |entry,i|
      skip = ARGV[2]
      if skip.present? && i < skip.to_i 
       puts "#{i} - "
       next
      end 
    
    orgs = entry.os.map {|os| os['os']}
    
    unless orgs.include?('Homo sapiens') || orgs.include?('Mus musculus') || orgs.include?('Arabidopsis thaliana') || orgs.include?('Escherichia coli')  || orgs.include?('Saccharomyces cerevisiae')    
      @skipped = @skipped.next
      puts "\tskipped - #{@skipped} " 
      next
    else
      $stdout.sync = true
      
  
     
      p = Protein.find_by_ac(entry.accessions[0])
  
  
      
      if p.present? 
        # delete old names
        p.proteinnames.map {|n| n.destroy}
        
        # Extract recommendet and alternative names from "de" string
        recnames = entry.de.match(/^RecName: (.*?)( AltName|$)/)
          recnames = recnames[1].split('RecName') if recnames 
        subnames = entry.de.match(/^SubName: (.*?)( AltName|$)/)
          subnames = subnames[1].split('SubName') if subnames
        altnames = entry.de.match(/RecName: .*?; AltName:(.*?)( Contains| Flags|$)/)
          altnames = altnames[1].split('AltName') if altnames
        recname = Hash.new
      
        if recnames
          temp = recnames.shift
          temp.match(/Full=.*?;/) ? recname['full'] = temp.match(/Full=(.*?);/)[1] : recname['full'] = ''
          temp.match(/Short=.*?;/) ? recname['short'] = temp.match(/Short=(.*?);/)[1] : recname['short'] = ''
        elsif subnames
          temp = subnames.shift
          temp.match(/Full=.*?;/) ? recname['full'] = temp.match(/Full=(.*?);/)[1] : recname['full'] = ''
          temp.match(/Short=.*?;/) ? recname['short'] = temp.match(/Short=(.*?);/)[1] : recname['short'] = ''
        end
        
        altname = Array.new
        if recnames
          recnames.each do |name|
            name.match(/Full=.*/) ? altname.push({'full' => name.match(/Full=(.*)/)[1]})  : 1
            name.match(/Short=(.*)/) ? altname[altname.length-1].merge!({'short' => name.match(/Short=(.*)/)[1]}) :1
          end
        end   
        if altnames
          altnames.each do |name|
            name.match(/Full=.*/) ? altname.push({'full' => name.match(/Full=(.*)/)[1]})  : 1
            name.match(/Short=(.*)/) ? altname[altname.length-1].merge!({'short' => name.match(/Short=(.*)/)[1]}) :1
          end
        end     
        if subnames
          subnames.each do |name|
            name.match(/Full=.*/) ? altname.push({'full' => name.match(/Full=(.*)/)[1]})  : 1
            name.match(/Short=(.*)/) ? altname[altname.length-1].merge!({'short' => name.match(/Short=(.*)/)[1]}) :1
          end
        end           
        
        puts "#{p.ac} - #{p.definition.match(/ull=(.*?);/)[1]} - #{recname['full']}" if p.definition.match(/ull=(.*?);/)[1] != recname['full']
        
        p.proteinnames.create(:full => recname['full'], :short => recname['short'], :recommended => true)
        if altname 
          altname.each do |name|
            p.proteinnames.create(:full => name['full'], :short => recname['short'], :recommended => false)
          end
        end
        
        ## add gene symbol name with stripped species as altname (eg 1433B for 1433B_HUMAN)
        p.proteinnames.create(:full => entry.id_line['ENTRY_NAME'].to_s.split('_')[0], :short => '', :recommended => false)
        print "."
      end
    end
  end
end  


desc "import uniprot gene names"
task :import_uniprot_gene_names do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  case ARGV[1]
    when 'human' 
      io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_human.dat.gz")
    when 'mouse'
      io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_rodents.dat.gz") 
    when 'arabidopsis'
      io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_plants.dat.gz")
    when 'arabidopsis-trembl'
      io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_trembl_plants.dat.gz")
    when 'ecoli'
      io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_bacteria.dat.gz")
    when 'yeast'
      io = Zlib::GzipReader.open("#{RAILS_ROOT}/databases/uniprot_sprot/uniprot_sprot_fungi.dat.gz")
  end
  puts "done"
    
    @skipped = 0
    @added = 0
    @updated = 0
    
    
  puts "before file open"
  Bio::FlatFile.open(io).each_with_index do |entry,i|
      skip = ARGV[2]
      if skip.present? && i < skip.to_i 
       puts "#{i} - "
       next
      end 
    
    orgs = entry.os.map {|os| os['os']}

    unless orgs.include?('Homo sapiens') || orgs.include?('Mus musculus') || orgs.include?('Arabidopsis thaliana') || orgs.include?('Escherichia coli')  || orgs.include?('Saccharomyces cerevisiae')    
      @skipped = @skipped.next
      puts "\tskipped - #{@skipped} " 
      next
    else
      $stdout.sync = true
      
  
     
      p = Protein.find_by_ac(entry.accessions[0])
  
  
      
      if p.present? 
        entry.gn.each do |g|
          unless g.class == Hash
            cannonical_key = {'ORFNames' => :orfs, 'Name' => :name, 
                    'OrderedLocusNames' => :loci}
            g2 = {}
            g.to_s.split(';').map {|x| x.strip }.each do |ge|
              key, value = ge.split('=')
              g2[cannonical_key[key]] = value
            end
            g = g2
          end
          g[:synonyms] = [] unless g[:synonyms]
          g[:name] = '' unless g[:name]
          g[:loci] = [] unless g[:loci]
          g[:orfs] = [] unless g[:orfs]
          gene = p.create_gn(:name => g[:name])
          
          g[:synonyms].each do |synonym|
            # temp = GnSynonym.find_or_create_by_synonym(:synonym => synonym)
            gene.synonyms.create(:synonym =>synonym) if gene.present?
          end 
              # altname.each do |name|
                # p.proteinnames.create(:full => name['full'].delete(';'), :short => recname['short'].delete(';'), :recommended => false)
              # end
         end
       end
     end
   end
end


desc "populate searchnames table with a set of searchable names and ids"
task :populate_searchnames do
  require "#{RAILS_ROOT}/config/environment"

  
  ActiveRecord::Base.connection.execute('TRUNCATE searchnames') 
    
  Protein.all.each do |p| 
    p.searchnames.find_or_create_by_name(:name => p.name) if p.name.present?
        p.searchnames.find_or_create_by_name(:name => p.ac)  if p.ac.present?
    p.proteinnames.each do |n|
      p.searchnames.find_or_create_by_name(:name => n.full) if n.full.present?
      p.searchnames.find_or_create_by_name(:name => n.short) if n.short.present?
    end
    
    if p.gn.present?
      p.searchnames.find_or_create_by_name(:name => p.gn.name) if p.gn.name.present?
      
      p.gn.synonyms.each do |n|
        p.searchnames.find_or_create_by_name(:name => n.synonym) if n.synonym.present?
      end
    end    
    p.searchnames.find_or_create_by_name(:name => p.meropsfamily) if p.meropsfamily.present?
    p.searchnames.find_or_create_by_name(:name => p.meropssubfamily) if p.meropssubfamily.present?
    p.searchnames.find_or_create_by_name(:name => p.meropscode) if p.meropscode.present?
  
  end

end


desc "write meropscodes from drs to protein itself"
task :write_meropscodes do
  require "#{RAILS_ROOT}/config/environment"

  Protein.drs_db_name_is('MEROPS').each do |p|
    merdrs = p.drs.db_name_is('MEROPS')

    #select protease entry for multi domain protease / inhibitors 
    merdr = merdrs.first
    if merdrs.count >> 1 && merdr.protein_name.match(/^I/)
      merdrs.map {|x| merdr = x unless x.protein_name.match(/^I/)}
    end
      
    code = merdr.protein_name if merdr.present?
    mer = Merops.find_by_code(code) if merdr.present?
    fam = mer.family if mer.present?
    subfam = mer.subfamily if mer.present?
    Protein.find(p.id).update_attributes(:meropscode => code,:meropsfamily => fam,:meropssubfamily => subfam) if mer.present?
    puts "#{merdrs.count}"
    puts " - code:#{code} fam:#{fam} subfam:#{subfam}" if merdrs.present?
    
  end

end
