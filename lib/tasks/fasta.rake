desc "convert chibi fasta file to clipper annotate compatible fasta file "
task :convert_fasta do
   require "#{RAILS_ROOT}/config/environment"
  require 'bio'
  require 'zlib'
  

  File.open("#{ARGV[1]}-clipper.fasta", 'w') do |f|
    Bio::FlatFile.open(ARGV[1]).each_with_index do |entry,i|
      # if i == 1 
      #   break
      # end

      definition = entry.definition.to_s.gsub(/^IPI/,'IPI:IPI')
      definition.gsub!(/ (TREMBL:)/,'|TREMBL:') 
      definition.gsub!(/ (ENSEMBL:)/,'|ENSEMBL:') 
      definition.gsub!(/ (SWISS-PROT:)/,'|SWISS-PROT:') 
      definition.gsub!(/ (REFSEQ:)/,'|REFSEQ:') 
      definition.gsub!(/ (VEGA:)/,'|VEGA:') 
      
      f.write entry.aaseq.to_fasta(definition,80)

    end
  end
end