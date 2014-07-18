desc "import cleavages from merops"
task :import_merops_cleavages do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'  
  require 'merops'
  
#  cleavages = Mcleavage.all

  proteases = Protein.drs_db_name_equals('MEROPS').uniq
  @total = proteases.count  
  puts "starting import of #{@total} proteases"
  @added = 1 
  @padded =1 

  #one evidence source for all MEROPS entries
  @esource = Evidencesource.find_or_create_by_dbname(
          :dbname => 'MEROPS',
          :dburl => 'http://merops.sanger.ac.uk/',
          :dbdesc => 'MEROPS the peptidase database'
        )
  @esource.save      


  proteases.each_with_index do |@p,@pi|
    # get the merops id for the protein from the drs table
    @merid = @p.drs.find_by_db_name('MEROPS').protein_name
    #get all cleavages for this protease from merops
    cleavages = Mcleavage.code_equals(@merid)
    
    # iterate over all cleavages for this protease in merops
    cleavages.each_with_index do |@c,@ci|
      #find all matching protein entries for merops substrates through uniprot_acc in acs table
      substrates = Protein.acs_name_is(@c.uniprot_acc)
      #iterate over all substrates and add the cleavage 'protease/substrate' for each to the db
      substrates.each_with_index do |@s,@si|
        
        #don't add if protease and substrate species don't match
        next unless @p.species.present? && @s.species.present?
        next if @p.species.name != @s.species.name
        
        #if @added < 6200
        #	print "#{@added}, "
        #	@added = @added.next
        #	next
        #end		
       
        puts "\t#{@pi}/#{@total}/#{@padded}/#{@added}-#{@ci}-#{@si}: #{@p.ac} - #{@p.name}  | #{@s.ac} - #{@s.name}"

        #for PICS based cleavages >> don't attribute it to a protein substrate but create only cleavagesite
        @c.cleavage_notes.present? ? notes = @c.cleavage_notes.lstrip : notes = ''
        @c.cleavage_evidence.present? ? merevidence = @c.cleavage_evidence.lstrip : merevidence = ''
        tdesc = "Imported from Merops:
        #{notes}
        Merops-evidence: #{merevidence} | Merops-type: #{@c.cleavage_type} | Merops-range: #{@c.residue_range}"
        case @c.cleavage_type
        	when 'physiological'
        		tphysiol = 'yes'
        	when 'non-physiological'
        		tphysiol = 'none'
        	else 
        		tphysiol = 'unknown'
        end
        texturl = "http://merops.sanger.ac.uk/cgi-bin/merops.cgi?id=#{@merid};action=default"
       
        if notes.include?('PICS')
          pics = 'PICS' 
          seqarray = @s.sequence.split(//).unshift('')
          seqarray[@c.p1+1..@c.p1+11] ? primeseq = seqarray[@c.p1+1..@c.p1+11] : primeseq = ''
          seqarray[1..@c.p1] ? nonprimeseq = seqarray[1..@c.p1].reverse[0..9].reverse : nonprimeseq = ''
          peptide = "#{nonprimeseq}:#{primeseq}"
          substrate = nil
          idstring = "P(#{@p.ac})-Pep(#{peptide})"
          ename = "PICS #{@p.name} -> #{peptide}" 
          method = 'PICS'
        else
          pics = ''
          peptide = nil
          substrate = @s.id
          idstring = "P(#{@p.ac})-S(#{@s.ac})at(#{@c.p1})" 
          ename = "Merops #{@p.name} -> #{@s.name} @#{@c.p1}"  
          @c.peptidase_identification.present? ? method = "Protease identification: #{@c.peptidase_identification}" : method = ''
          method.present? && @c.peptide_identification.present? ? method << ' | ' : method << ''
          @c.peptide_identification.present? ? method << "Substrate identification: #{@c.peptide_identification}" : method << ''                              
        end
        
        eidstring = "#{idstring}-#{merevidence}-#{tphysiol}-unknown-#{@c.pmid}"


        
        newcleavage = Cleavage.find_or_create_by_idstring(
          :idstring => idstring,
          :protease_id => @p.id,
          :substrate_id => substrate,
          :peptide => peptide,
          :pos => @c.p1
        )
        
        if @c.pmid
        	epub = Publication.find_or_create_by_pmid(
        	  :pmid => @c.pmid
        	) 
        end
        if epub.present?
            authors = epub.authors.split(',')
        	elab = authors.last.lstrip if authors.present?
        	ename = "#{authors.first} et al.:#{epub.title[0..30]}... (#{@merid})"
			eidstring = "#{merevidence}-#{tphysiol}-unknown-#{@c.pmid}"        	
        else	
        	elab = ''
        	ename = ename
			eidstring = "#{idstring}-#{merevidence}-#{tphysiol}-unknown-#{@c.pmid} (#{@merid})"        	
        end
        	        
        newevidence =  Evidence.find_or_create_by_idstring(:idstring => eidstring) do |e|
          e.name = ename
          e.description = tdesc
          e.phys_relevance = tphysiol
          e.method = method
          e.lab = elab
          e.directness = 'unknown'
        end

        
        if epub.present?
        	newevidence.publications.include?(epub) ? 1 : newevidence.publications << epub 
        end
        
        newevidence.evidencesource = @esource
              
        if merevidence == 'experimental'
          ecode = Evidencecode.find_or_create_by_code(:name => 'inferred from experiment', :code => 'ECO:0000006')
          newevidence.evidencecodes.include?(ecode) ? 1 : newevidence.evidencecodes << ecode
        elsif merevidence == 'theoretical'
          ecode =  Evidencecode.find_or_create_by_code(:name => 'inferred from in-silico analysis', :code => 'ECO:0000036')
          newevidence.evidencecodes.include?(ecode) ? 1 : newevidence.evidencecodes << ecode
        end        
        
        newcleavage.evidences.include?(newevidence) ? 1 : newcleavage.evidences << newevidence
        
        #newcleavage.process_termini
        #newcleavage.process_cleavagesite
        newcleavage.map_to_isoforms
        
        @added = @added.next
      end
    end
    @padded = @padded.next if !cleavages.empty? 
    end
end


desc "import inhibitions by protein inhibitors from merops"
task :import_merops_inhibitions do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio' 
  require 'merops'
  
  merproteins = Protein.drs_db_name_equals('MEROPS').uniq
  @total = merproteins.count  
  @added = 1 
  @mpadded =1 

  #one evidence source for all MEROPS entries
  @esource = Evidencesource.find_or_create_by_dbname(
          :dbname => 'MEROPS',
          :dburl => 'http://merops.sanger.ac.uk/',
          :dbdesc => 'MEROPS the peptidase database'
        )
        
  @ecode = Evidencecode.find_or_create_by_code(:code =>'ECO:0000203', 
    :name => "inferred from electronic annotation",
    :definition => "Used for annotations that depend directly on computation or automated transfer of annotations from a database, particularly when the analysis is performed internally and not published. A key feature that distinguishes this evidence code from others is that it is not made by a curator; use IEA when no curator has checked the specific annotation to verify its accuracy. The actual method used (BLAST search, Swiss-Prot keyword mapping, etc.) doesn't matter." 
  )  

  merproteins.each_with_index do |@mp,@mpi|
    # get the merops id for the protein from the dbxref table
    @merid = @mp.drs.db_name_equals('MEROPS').first.protein_name
    #get all inhibitions for this inhibitor from merops
    inhibitions = Minhibition.inhibitor_code_equals(@merid)
    
    #iterate over all inhibitions for this protease in merops
    inhibitions.each_with_index do |@i,@ii|
      #find all matching protein entries for merops inhibited substrates through peptdiase_code merops id in dbxrefs table
      proteases = Protein.drs_protein_name_equals(@i.peptidase_code).drs_db_name_equals('MEROPS')

      #iterate over all protease and add the inhibition 'inhibitor/substrate' for each to the db
      proteases.each_with_index do |@p,@pi|
        
        # don't add if inhibited protease and inhibitor species don't match
        next if @mp.species.name != @p.species.name
        @i.conditions.present? ? conditions = @i.conditions.lstrip : conditions = ''   
        
        
        puts "\t#{@mpi}/#{@total}/#{@mpadded}/#{@added}-#{@ii}-#{@pi}: #{@mp.ac} - #{@merid} -#{@mp.name}  | #{@p.ac} - #{@i.peptidase_code} - #{@p.name} "
        ename = "Merops #{@i.peptidase_code} - #{@i.inhibitor_code}"
        tdesc = "Merops-Ki: #{@i.Ki} | Merops-conditions: #{conditions}"     
        texturl = "http://merops.sanger.ac.uk/cgi-bin/pepsum?mid=#{@merid}"
        idstring = "I(#{@i.inhibitor_code})-P(#{@i.peptidase_code})"
        eidstring = "#{idstring}-unknown-unknown-#{@i.pmid}"
               
        newinhibition = Inhibition.find_or_create_by_idstring(
          :idstring => idstring,
          :inhibitor_id => @mp.id,
          :inhibited_protease_id => @p.id
        )
        
        if @i.pmid
        	epub = Publication.find_or_create_by_pmid(
        	  :pmid => @i.pmid
        	) 
        end
        if epub.present?
            authors = epub.authors.split(',')
        	elab = authors.last.lstrip if authors.present?
        	ename = "#{authors.first} et al.:#{epub.title[0..30]}... (#{@merid})"
			eidstring = "#unknown-unknown-#{@i.pmid}"        	
        else	
        	elab = ''
        	ename = ename
			eidstring = "#{idstring}-unknown-unknown-#{@i.pmid} (#{@merid})"        	
        end
                
        newevidence = Evidence.find_or_create_by_idstring(:idstring => eidstring) do |e|
          e.name = ename
          e.description = tdesc
          e.phys_relevance = 'unknown'
          e.directness ='unknown'
          e.lab = elab
          e.method = ''
        end

        if epub.present?
        	newevidence.publications.include?(epub) ? 1 : newevidence.publications << epub 
        end
        
        newevidence.evidencesource = @esource
        newevidence.evidencecodes.include?(@ecode) ? 1 : newevidence.evidencecodes << @ecode
        newinhibition.evidences.include?(newevidence) ? 1 : newinhibition.evidences << newevidence

        @added = @added.next
      end
    end
    @mpadded = @mpadded.next if !inhibitions.empty? 
  end
end

desc "import small molecule inhibitors and inhibitions from merops"
task :import_merops_smi do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio' 
  require 'merops'

  smis = Msmi.all
  smis.each do |smi|
    puts "#{smi.code} - #{Msminame.find_by_code(smi.code, :conditions => {:type => 'real'}).try(:name)}"
    @molecule = Molecule.create(
      :name => Msminame.find_by_code(smi.code, :conditions => {:type => 'real'}).try(:name),
      :external_id => smi.code,
      :source => 'MEROPS',
      :formula => smi.elemental_formula
    ) 
    
    names = Msminame.code_equals(smi.code).each do |name|
      puts name.name
      @molecule.moleculenames.create(:name => name.name)     
    end
  end
  
end