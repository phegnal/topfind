desc "go stuff"
task :uniprot2gomapping => :environment do

  filename = 'uniprot2go.map'

  path = '/Users/PhilippLange/Documents/science/data/data-analysis/'
  date = Date::today.to_s
  Dir.chdir(path)
  Dir.mkdir(date) unless  File.exists?(date)
  Dir.chdir(date)

  

  File.open(filename,'w') do |f| 
    Protein.all.each do |p|
      row = "#{p.ac}\t"
      p.drs.db_name_is('GO').each do |go|
        row << "#{go.protein_name}, "
      end
      row << "\n"
      f << row
    end
  end

end 