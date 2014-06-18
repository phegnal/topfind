desc "nterms including proteins used in fig1c yeast requested by joerg gsponer"
task :nterms => :environment do
  
  require 'fastercsv'

	filename = 'nterms-at-2'
	
	# path = '/Users/philipp/Documents/science/data/data-analysis/'
	path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topfind_analysis/'
	date = Date::today.to_s
	Dir.chdir(path)
	Dir.mkdir(date) unless  File.exists?(date)
	Dir.chdir(date)	
	
	 
	nterms = Nterm.evidences_evidencecodes_name_is('inferred from experiment').uniq
	
	FasterCSV.open("#{filename}.csv", "w") do |csv|
		
		csv << ['Species','Protein (UniProt Acc)','Name','Position','AS','Sequence']
		count = 0
		hcount = 0
		mcount = 0
		ycount = 0
		nterms.each do |n|
			if n.pos == 2
  			count +=1
  			hcount += 1 if n.protein.oss.first.name == 'Homo sapiens'
  			mcount += 1 if n.protein.oss.first.name == 'Mus musculus'
  			ycount += 1 if n.protein.oss.first.name == 'Saccharomyces cerevisiae'
  			sequence = n.protein.sequence.split('')[n.pos-1..n.pos+9].join('')
  			termas = n.protein.sequence.split('')[n.pos-1] 
  			csv << [n.protein.oss.first.name,n.protein.ac,n.protein.recname,n.pos,termas,sequence]
			end
		end
		puts "#{count} Nterms, H:#{hcount} / M:#{mcount} / Y:#{ycount}"
  end
end
