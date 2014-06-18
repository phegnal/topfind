desc "populate chpp ch6 protein table from topcat uniprot and biomart"
task :ch6_populate => :environment do
  
  require 'fastercsv'
  require 'biomart'

  Biomart.timeout = 1800   
  biomart = Biomart::Server.new( "http://www.biomart.org/biomart" )  
  puts "biomart connected" 
  @mart = biomart.datasets["hsapiens_gene_ensembl"]
    
  gmart = @mart.search(:filters=> {'chromosome_name' => 6}, :attributes => ['ensembl_gene_id','uniprot_swissprot_accession','hpa','cell_type','anatomical_system','band'])
  genes = gmart[:data]
  count = 0
  # total = Protein.oss_name_is('Homo sapiens').chromosome_is('6').count
  total = genes.count
  
  
  expnterms = Nterm.evidences_evidencecodes_name_is('inferred from experiment').*.id.uniq
  prednterms = Nterm.evidences_evidencecodes_name_is_not('inferred from experiment').*.id.uniq
  expcterms = Cterm.evidences_evidencecodes_name_is('inferred from experiment').*.id.uniq
  predcterms = Cterm.evidences_evidencecodes_name_is_not('inferred from experiment').*.id.uniq
   
  genes.each do |g|
  	count = count+=1
	# break if count == 10
	puts "#{count}/#{total}"
  	g[0].present? ? gene = g[0] : gene = ''
  	g[1].present? ? uniprot = g[1] : uniprot = ''
  	g[2].present? ? hpa = g[2] : hpa = ''
  	g[3].present? ? celltype = g[3] : celltype = ''
  	g[4].present? ? anatomical_system = g[4] : anatomical_system = ''
  	developmental_stage = ''
  	pathology = ''
  	g[5].present? ? band = g[5] : band = ''
  	gocell = ''
  	pubmed = ''
  	
  	p = Protein.drs_protein_name_is(uniprot).first
  	
  	protein = Ch6protein.find_or_create_by_ensembl(gene)
  	if p.present?
  		protein.name = p.ac
  	else
  		protein.name = gene
  	end
  	
  	protein.ensembl = protein.ensembl.split(',').push(gene).uniq.join(',')
  	protein.save
  	protein.uniprot_ac = protein.uniprot_ac.split(',').push(uniprot).uniq.join(',')
  	protein.save
  	protein.ch6_location = "6#{band}"
  	protein.save
  	protein.protein_atlas = protein.protein_atlas.split(',').push(hpa).uniq.join(',')
  	protein.save
  	protein.tissue_distribution.present? ? protein.tissue_distribution = protein.tissue_distribution.split(',').push(celltype).uniq.join(',') : protein.tissue_distribution = celltype
  	protein.save
  	protein.tissue_distribution.present? ? protein.tissue_distribution = protein.tissue_distribution.split(',').push(anatomical_system).uniq.join(','): protein.tissue_distribution = anatomical_system
  	protein.save
  	protein.tissue_distribution.present? ? protein.tissue_distribution = protein.tissue_distribution.split(',').push(developmental_stage).uniq.join(',') : protein.tissue_distribution = developmental_stage
  	protein.save
  	# protein.pathology.present? ? protein.pathology = protein.pathology.split(',').push(pathology).uniq.join(',') : protein.pathology = pahtology
  	# protein.save
  	protein.subcellular_distribution.present? ? protein.subcellular_distribution = protein.subcellular_distribution.split(',').push(gocell).uniq.join(',') : protein.subcellular_distribution = gocell
  	protein.save
  	protein.general_publications.present? ? protein.general_publications = protein.general_publications.split(',').push(pubmed).uniq.join(','): protein.general_publications = pubmed
  	protein.save
  	

	
	if p.present?
		protein.uniprot_annotation = ''
		p.ccs.each do |a|
			protein.uniprot_annotation << "#{a.topic}: #{a.contents}\n\n"
		end 
	  	protein.save
	  	protein.merops = p.merid
	  	protein.save		
  		protein.msms = true if (p.nterms.*.id & expnterms).present?
  		protein.save
		protein.nterms_observed = p.nterms.evidences_evidencecodes_name_is('inferred from experiment').uniq.count
  		protein.save
		protein.nterms_predicted = p.nterms.count
  		protein.save
		protein.cterms_observed = p.cterms.evidences_evidencecodes_name_is('inferred from experiment').uniq.count
  		protein.save
		protein.cterms_predicted = p.cterms.count
  		protein.save
	end  	
     	
  end
end


desc "write all chromosome 6 proteins into textfile for wikipage"
task :chr6totxt => :environment do
  
  require 'fastercsv'
  require 'biomart'

  Biomart.timeout = 1800   
  biomart = Biomart::Server.new( "http://www.biomart.org/biomart" )  
  puts "biomart connected" 
      @mart = biomart.datasets["hsapiens_gene_ensembl"]
    


  filename = 'chr-6.txt'

  # path = '/Users/philipp/Documents/science/data/data-analysis/'
  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/hpp_analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)
  
  count = 0
  total = Protein.oss_name_is('Homo sapiens').chromosome_is('6').count
  
  expnterms = Nterm.evidences_evidencecodes_name_is('inferred from experiment').*.id.uniq

  FasterCSV.open("#{filename}.csv", "w") do |csv|

  File.open(filename,'w') do |f|
    f << "{| class='wikitabl'\n"
    f << "|-\n"
    header = "! NAME !! Common name !! UniProt entry !! Chr 6 location !! ProteinAtlas !! PeptideAtlas !! MRM Atlas !! Tissue distribution !! # termini || MS/MS || SRM || AB || Ensembl || Link to other information\n"
    f << header
    f << "|-\n"

    csvheader = ["NAME","Common name","UniProt entry","Chr 6 location","ProteinAtlas","PeptideAtlas",'MRM Atlas',"Tissue distribution","# termini","MS/MS","SRM","AB","Ensembl","Link to other information"]
    csv << csvheader

    
    Protein.oss_name_is('Homo sapiens').chromosome_is('6').each do |p|
    	
      proteinatlas = ''	
      tissues = ''
	  if @mart
      	pmart = @mart.search(:filters => {'uniprot_swissprot_accession' => p.ac},:attributes => ['hpa','cell_type'])
      	proteinatlas = "[http://www.proteinatlas.org/tissue_profile.php?antibody_id=#{pmart[:data].flatten[0]} #{pmart[:data].flatten[0]}]" if pmart[:data].flatten[0].present?
      	csvproteinatlas = "http://www.proteinatlas.org/tissue_profile.php?antibody_id=#{pmart[:data].flatten[0]}" if pmart[:data].flatten[0].present?
      	tissues = pmart[:data].flatten[1] if pmart
      end    	
    	count = count+=1
    	# break if count == 10
    	puts "#{count}/#{total}"
    	
    	uniprot = "[http://www.uniprot.org/uniprot/#{p.ac} #{p.ac}]"
    	csvuniprot = "http://www.uniprot.org/uniprot/#{p.ac}"
    	(p.nterms.*.id & expnterms).present? ? ms = 'X' : ms = ''
    	ensembl = ""
    	csvensembl =""
    	peptideatlas = '' 
    	csvpeptideatlas =""
    	p.drs.each do |dr|
    		case dr.db_name
    			when 'Ensembl' 	
		    		ensembl << "[http://uswest.ensembl.org/Homo_sapiens/Gene/Summary?g=#{dr.protein_name} #{dr.protein_name}] / "
		    		csvensembl << "http://uswest.ensembl.org/Homo_sapiens/Gene/Summary?g=#{dr.protein_name};"
	    		when 'PeptideAtlas'
		    		peptideatlas << "[https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/GetProtein?protein_name=#{dr.protein_name}&action=QUERY #{dr.protein_name}] / "
		    		csvpeptideatlas << "https://db.systemsbiology.net/sbeams/cgi/PeptideAtlas/GetProtein?protein_name=#{dr.protein_name}&action=QUERY;"
		    end   		
    	end
    	mrmatlas = ''
    	tissues = '' 
    	
    	row = "| #{p.name} || #{p.recname} || #{uniprot} || 6#{p.band} || #{proteinatlas} || #{peptideatlas} || #{mrmatlas} || #{tissues} || #{p.nterms.count} || #{ms} || || || #{ensembl}|| \n"
    	f << row
    	
    	csvrow = [p.name,p.recname,csvuniprot,"6#{p.band}",csvproteinatlas,csvpeptideatlas,mrmatlas,tissues,"#{p.nterms.count}",ms,'','',csvensembl,'']
    	csv << csvrow
    	f << "|-\n"
    end
    f << "|}\n" 

  end
  end
end

