namespace :export_cleavages do

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
  
  # I checked - this returns the same as the mysql query
  desc "export cleavage sites tab (to compare to phophorylation sites)"
  task :export_table => :environment do
    
    f = File.new("#{RAILS_ROOT}/Exported_cleavages.tab", "w")
    
    f << "# Cleavage data downloaded from TopFIND on May 22, 2015\n"
    f << "Protease\tSubstrate\tPos\tSequence\n"
        
    Protein.species_name_is("Homo sapiens").select{|p| p.ac.match(/\-\d/).nil?}.each do |p|
      p.cleavages.each{|c|
        if !c.cleavagesite.nil? && !c.protease.nil? && !c.substrate.nil?
          f << "#{c.protease.ac}\t#{c.substrate.ac}\t#{c.pos}\t#{c.cleavagesite.seq}\n"
        end
      }
    end
    
    f.close
    
  end
  
end