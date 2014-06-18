desc "converttails"
task :converttails => :environment do
  
  require 'fastercsv'

  filename = ARGV[1]

  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat-datasets/own'
  # date = Date::today.to_s
  Dir.chdir(path)
  # Dir.mkdir(date) unless  File.exists?(date)
  # Dir.chdir(date) 
  
  FasterCSV.open("#{filename}-out.csv", "w") do |csv|
  	  csv << 'protein,position,modification,oldpos,pep,quant'
	  FasterCSV.foreach("#{filename}.csv",{:col_sep => ';'}) do |r|
	  	ac = r[0]
	  	puts ac
	  	pep = r[1].delete('0123456789[]n.')
	  	puts pep
	  	p = Protein.drs_protein_name_is(ac).first
	  	if p
	    	pos = p.sequence.index(pep)
	    	pos.present? ? pos = pos+1 : pos = ''
	    	puts pos
			csv << "#{p.ac},#{pos},#{r[4]},#{r[3]},#{pep},#{r[2]}"
		else
			csv << "NF-#{ac},XX,#{r[4]},#{r[3]},#{pep},#{r[2]}"
		end
	  end
	  puts 'file read'
  end
end
		
desc "convertctails"
task :convertctails => :environment do
  
  require 'fastercsv'

  filename = ARGV[1]

  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat-datasets/own'
  # date = Date::today.to_s
  Dir.chdir(path)
  # Dir.mkdir(date) unless  File.exists?(date)
  # Dir.chdir(date) 
  
  FasterCSV.open("#{filename}-out.csv", "w") do |csv|
  	  csv << 'protein,position,modification'
	  FasterCSV.foreach("#{filename}.csv",{:col_sep => ';'}) do |r|
	  	ac = r[0]
	  	puts ac
	  	pep = r[1].match(/\.(.*)\./)[1]
	  	puts pep
	  	p = Protein.ac_is(ac).first
	  	if p
	    	pos = p.sequence.index(pep)
	    	puts pos
	    	pos = pos + pep.length
			csv << "#{ac},#{pos},unknown"
		end
	  end
	  puts 'file read'
  end
end
  
desc "convertvoegtle"
task :convertvoegtle => :environment do
  
  require 'fastercsv'

  filename = ARGV[1]

  path = '/Volumes/MMPfileserver/lab/Documents/Philipp/topcat-datasets/gevaert'
  # date = Date::today.to_s
  Dir.chdir(path)
  # Dir.mkdir(date) unless  File.exists?(date)
  # Dir.chdir(date) 
  
  FasterCSV.open("#{filename}-out.csv", "w") do |csv|
  	  csv << 'protein,position,modification'
	  FasterCSV.foreach("#{filename}.csv",{:col_sep => ';'}) do |r|
	  	ac = r[0]
	  	puts ac
	  	pos = r[1]
	  	puts pos
	  	p = Protein.drs_protein_name_is(ac).first
		csv << "#{ac},#{pos},unknown"
	  end
  end
end  