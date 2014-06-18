desc "export cleavage sites to csv for pepcutter"
task :export_pepcutter_cleavages => :environment do
  
  require 'fastercsv'
  
  species = ['Mus musculus', 'Homo sapiens']
  
  species.each do  |s|
	sites = []
	filename ="topfind_cleavagesites_for_pepcutter-#{s}-2"
	
	path = '/Volumes/MMPfileserver/lab/Documents/Philipp/data/'
	date = Date::today.to_s
	Dir.chdir(path)
	Dir.mkdir(date) unless  File.exists?(date)
	Dir.chdir(date)
		
		
	Protein.species_name_is(s).each do |p|
		if p.cleavages.count > 0
			pc = []
			pc << p.shortname
			pc << p.cleavages.*.cleavagesite.compact.map {|c| c.seq_z}
			pc.flatten!
			sites << pc
		end	
	end	
		
		
	FasterCSV.open("#{filename}.csv", "w") do |csv|
        sites.each do |pc|
	y pc
        	csv << pc
		end
	end
  end 
end