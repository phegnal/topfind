desc "human nterms including proteins and evidences for Julia Seaman in Jim Wells lab as requested 120516"
task :wellslabexport => :environment do
  
require 'fastercsv'

	filename = 'TopFIND-human_ntermini-120604'

	# path = '/Users/philipp/Documents/science/data/data-analysis/'
	path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topfind_analysis/'
	date = Date::today.to_s
	Dir.chdir(path)
	Dir.mkdir(date) unless  File.exists?(date)
	Dir.chdir(date)	

	 
	nterms = Nterm.protein_species_name_is('Homo sapiens')

	FasterCSV.open("#{filename}.xls", "w",{:col_sep=>"\t"}) do |csv|
		
		csv << ['Nterm ID','Protein (UniProt Acc)','Name','Species','Nterm Position','Modification','evidence name','evidence description','evidence method',
				'evidence physiological relevance','evidence directness','evidence lab','evidence source','evidence code',
				'evidence experimental system','evidence tissue distribution']
		nterms.each do |n|
			n.evidences.each do |e|
				csv << ["TNt#{n.id}",n.protein.ac,n.protein.recname,n.protein.species.name,n.pos,n.terminusmodification.name,e.name,e.description.gsub(/[\r\n]/,' '),e.method,
						e.phys_relevance,e.directness,e.lab,"#{e.evidencesource.dbname if e.evidencesource}",e.evidencecodes.map {|ec| "#{ec.name} (#{ec.code})"}.join('|'),
						e.method_system,e.tissues.map {|t| t.name}.join('|')]
			end
		end
	end
end