desc "count as abundance in fasta file"
task :ascount do
  require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  
  io = Zlib::GzipReader.open(ARGV[1])
  outfile = "#{ARGV[2]}-as_abundance.csv"
  as = ['A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y']

  seqs = ''

  Bio::FlatFile.open(io).each_with_index do |entry,i|
    # if i == 22 
    #   break
    # end     
    orgs = entry.os.map {|os| os['os']}
    unless orgs.include?('Escherichia coli') || orgs.include?('Homo sapiens') || orgs.include?('Mus musculus') || orgs.include?('Saccharomyces cerevisiae')    #  
      next
    else    
      seqs << entry.seq.to_s
    end
  end

  total = seqs.length
  counts = Array.new
  percents = Array.new
  as.each do |c|
    counts << seqs.count(c)
    percents << seqs.count(c).to_f/total.to_f*100
  end 
  
  FasterCSV.open("#{outfile}", "w") do |csv|
    csv << as  
    csv << counts
    csv << percents
  end

end