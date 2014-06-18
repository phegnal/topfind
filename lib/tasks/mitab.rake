desc "export cleavages as mitab formatted tab file"
task :mitab_cleavages => :environment do
  
  require 'fastercsv'

  date = Date::today.to_s
  filename = "topfind-mitab-#{date}"

  path = 'psicquic/psicquic-mitab'
  Dir.chdir(path)
  
  FasterCSV.open("#{filename}.tab", "w", {:col_sep => "\t",:quote_char => "'"}) do |csv|
  csv << ['#ID(s) interactor A','ID(s) interactor B','Alt. ID(s) interactor A','Alt. ID(s) interactor B','Alias(es) interactor A','Alias(es) interactor B','Interaction detection method(s)','Publication 1st author(s)','Publication Identifier(s)','Taxid interactor A','Taxid interactor B','Interaction type(s)','Source database(s)','Interaction identifier(s)','Confidence value(s)','Experimental role(s) interactor A','Experimental role(s) interactor B','Biological role(s) interactor A','Biological role(s) interactor B','Properties interactor A','Properties interactor B','Type(s) interactor A','Type(s) interactor B','HostOrganism(s)','Expansion method(s)','Dataset name(s)','Annotation(s) interactor A','Annotation(s) interactor B','Parameter(s) interactor A','Parameter(s) interactor B','Parameter(s) interaction']  

    Cleavage.all.each do |c|
      next unless c.substrate.present?
      c.evidences.each do |e|
      
		  row = Array.new
		  row << "uniprotkb:#{c.protease.ac}" ##ID(s) interactor A
		  row << "uniprotkb:#{c.substrate.ac}" #ID(s) interactor B
		  
		  altproteaseids = c.protease.drs.map {|dr| "#{dr.db_name}:#{dr.protein_name}" if dr.db_name.present? && dr.protein_name.present? && !dr.protein_name.include?(':') && !dr.protein_name.include?('|') }.uniq.compact.join('|')
		  row << altproteaseids #Alt. ID(s) interactor A
		  
		  altsubstrateids = c.substrate.drs.map {|dr| "#{dr.db_name}:#{dr.protein_name}" if dr.db_name.present? && dr.protein_name.present? && !dr.protein_name.include?(':') && !dr.protein_name.include?('|')}.uniq.compact.join('|')
		  row << altsubstrateids #Alt. ID(s) interactor B
		  
		  #proteasealiases = c.protease.drs.map {|dr| "#{dr.db_name}:#{dr.protein_name}"}.uniq.join('|')
		  row << '-' #Alias(es) interactor A
		  
		  #substratealiases = c.substrate.drs.map {|dr| "#{dr.db_name}:#{dr.protein_name}"}.uniq.join('|')
		  row << '-' #Alias(es) interactor B
		  
		  row << '-' #Interaction detection method(s)
		  
		  if e.publications.first.present? && e.publications.first.pmid != 15389820 
		  	a =  e.publications.first.authors.split(',')[0]
		  	p =  "pubmed:#{e.publications.first.pmid}" 
		  else
		    a = '-'
		  	p = '-'
		  end
		  row << a #Publication 1st author(s)
		  row << p #Publication Identifier(s)
	
		  row << "taxid:#{c.protease.oxs.first.accession}(#{c.protease.species.common_name})" #Taxid interactor A
		  row << "taxid:#{c.protease.oxs.first.accession}(#{c.protease.species.common_name})"#Taxid interactor B
		  row << 'psi-mi:"MI:0570"(protein cleavage)' #Interaction type(s)
		  row << 'psi-mi:"MI:1117"(TopFind)' #Source database(s)
		  row << "topfind:#{c.id}-#{c.name}" #Interaction identifier(s)
		  
		  row << "#{e.confidence_type}:#{e.confidence}" #Confidence value(s)
		  row << '-' #Experimental role(s) interactor A
		  row << '-' #Experimental role(s) interactor B
		  row << 'psi-mi:"MI:0501"(enzyme)' #Biological role(s) interactor A
		  row << 'psi-mi:"MI:0502"(enzyme target)' #Biological role(s) interactor B
		  row << '-' #Properties interactor A
		  row << '-' #Properties interactor B
		  row << 'psi-mi:"MI:0326"(protein)' #Type(s) interactor A
		  row << 'psi-mi:"MI:0326"(protein)' #Type(s) interactor B
		  row << '-' #HostOrganism(s)
		  row << '-' #Expansion method(s)
		  row << '-' #Dataset name(s)
		  row << '-' #Annotation(s) interactor A
		  row << '-' #Annotation(s) interactor B
		  row << '-' #Parameter(s) interactor A
		  row << '-' #Parameter(s) interactor B
		  row << '-' #Parameter(s) interaction     
			
		 
		  csv << row
	  end
    end
  end
end


