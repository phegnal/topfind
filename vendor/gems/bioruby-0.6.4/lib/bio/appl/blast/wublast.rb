#
# bio/appl/blast/wublast.rb - WU-BLAST default output parser
# 
#   Copyright (C) 2003 GOTO Naohisa <ng@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: wublast.rb,v 1.1 2003/08/11 15:27:35 ng Exp $
#

require 'bio/appl/blast/format0'

module Bio
  class Blast
    module WU

      class Report < Default::Report

	def parameters
	  parse_parameters
	  @parameters
	end

	def parameter_matrix
	  parse_parameters
	  @parameter_matrix
	end

	def expect; parse_parameters; @parameters['E']; end

	def warnings
	  unless defined?(@warnings)
	    @warnings = @f0warnings
	    iterations.each { |x| @warnings.concat(x.warnings) }
	  end
	  @warnings
	end

	def notice
	  unless defined?(@notice)
	    @notice = @f0notice.to_s.gsub(/\s+/, ' ').strip
	  end #unless
	  @notice
	end

	private
	def format0_split_headers(data)
	  @f0header = data.shift
	  while r = data.first
	    case r
	    when /^Reference\: /
	      @f0reference = data.shift
	    when /^Copyright /
	      @f0copyright = data.shift
	    when /^Notice\: /
	      @f0notice = data.shift
	    when /^Query\= /
	      break
	    else
	      break
	    end
	  end
	  @f0query = data.shift
	  if r = data.first and !(/^Database\: / =~ r)
	    @f0translate_info = data.shift
	  end
	  @f0database = data.shift
	end

	def format0_split_search(data)
	  [ Iteration.new(data) ]
	end

	def format0_split_stat_params(data)
	  @f0warnings = []
	  if r = data.first and r =~ /^WARNING\: / then
	    @f0warnings << data.shift
	  end
	  @f0wu_params = []
	  @f0wu_stats = []
	  while r = data.shift and !(r =~ /^Statistics\:/)
	    @f0wu_params << r
	  end
	  @f0wu_stats << r if r
	  while r = data.shift
	    @f0wu_stats << r
	  end
	  @f0dbstat = F0dbstat.new(@f0wu_stats)
	  itr = @iterations[0]
	  itr.f0dbstat = @f0dbstat if itr
	end

	def parse_parameters
	  unless defined?(@parse_parameters)
	    @parameters = {}
	    @parameter_matrix = []
	    @f0wu_params.each do |x|
	      if /^  Query/ =~ x then
		@parameter_matrix << x
	      else
		x.split(/^/).each do |y|
		  if /\A\s*(.+)\s*\=\s*(.*)\s*/ =~ y then
		    @parameters[$1] = $2
		  elsif /\AParameters\:/ =~ y then
		    ; #ignore this
		  elsif /\A\s*(.+)\s*$/ =~ y then
		    @parameters[$1] = true
		  end
		end
	      end
	    end
	    @parse_parameters = true
	  end
	end

	class F0dbstat < Default::Report::F0dbstat
	  def initialize(ary)
	    @f0stat = ary
	    @hash = {}
	  end

	  #undef :f0params
	  #undef :matrix, :gap_open, :gap_extend,
	  #  :eff_space, :expect, :sc_match, :sc_mismatch,
	  #  :num_hits

	  def parse_dbstat
	    unless defined?(@parse_dbstat)
	      @f0stat.each do |x|
		parse_colon_separated(@hash, x)
	      end
	      @database = @hash['Database']
	      @posted_date = @hash['Posted']
	      if val = @hash['# of letters in database'] then
		@db_len =  val.tr(',', '').to_i
	      end
	      if val = @hash['# of sequences in database'] then
		@db_num = val.tr(',', '').to_i
	      end
	      @parse_dbstat = true
	    end #unless
	  end #def
	  private :parse_dbstat

	end #class F0dbstat

	class Frame
	end #class FrameParams

	class Iteration < Default::Report::Iteration
	  def initialize(data)
	    @f0stat = []
	    @f0dbstat = nil
	    @f0hitlist = []
	    @hits = []
	    @num = 1
	    @f0message = []
	    @f0warnings = []
	    return unless r = data.shift
	    @f0hitlist << r
	    return unless r = data.shift
	    unless /\*{3} +NONE +\*{3}/ =~ r then
	      @f0hitlist << r
	      while r = data.first and /^WARNING\: / =~ r
		@f0warnings << data.shift
	      end
	      while r = data.first and /^\>/ =~ r
		@hits << Hit.new(data)
	      end
	    end #unless
	  end

	  def warnings
	    @f0warnings
	  end

	  private
	  def parse_hitlist
	    unless defined?(@parse_hitlist)
	      r = @f0hitlist.shift.to_s
	      if /Reading/ =~ r and /Frame/ =~ r then
		flag_tblast = true 
		spnum = 5
	      else
		flag_tblast = nil
		spnum = 4
	      end
	      i = 0
	      @f0hitlist.each do |x|
		b = x.split(/^/)
		b.collect! { |y| y.empty? ? nil : y }
		b.compact!
		b.each do |y|
		  y.strip!
		  y.reverse!
		  z = y.split(/\s+/, spnum)
		  z.each { |y| y.reverse! }
		  dfl  = z.pop
		  h = @hits[i] 
		  unless h then
		    h = Hit.new([ dfl.to_s.sub(/\.+\z/, '') ])
		    @hits[i] = h
		  end
		  z.pop if flag_tblast #ignore Reading Frame
		  scr = z.pop.to_s
		  pval = z.pop.to_s
		  nnum = z.pop.to_i
		  #ev = '1' + ev if ev[0] == ?e
		  h.instance_eval {
		    @score = scr
		    @pvalue = pval
		    @n_number = nnum
		  }
		  i += 1
		end
	      end #each
	      @parse_hitlist = true
	    end #unless
	  end
	end #class Iteration

	class Hit < Default::Report::Hit
	  def initialize(data)
	    @f0hitname = data.shift
	    @hsps = []
	    while r = data.first
	      if r =~ /^\s*(?:Plus|Minus) +Strand +HSPs\:/ then
		data.shift
		r = data.first
	      end
	      if /^\s+Score/ =~ r then
		@hsps << HSP.new(data)
	      else
		break
	      end
	    end
	    @again = false
	  end

	  def score
	    @score
	  end
	  attr_reader :pvalue, :n_number
	end #class Hit

	class HSP < Default::Report::HSP
	  method_after_parse_score :pvalue, :p_sum_n
	end #class HSP

      end #class Report

      class Report_TBlast < Report
	DELIMITER = RS = "\nTBLAST"
      end #class Report_TBlast

    end #module WU
  end #class Blast
end #module Bio

######################################################################

if __FILE__ == $0

  Bio::FlatFile.open(Bio::Blast::WU::Report, ARGF) do |ff|
  ff.each do |rep|

  print "# === Bio::Blast::WU::Report\n"
  puts
  print "  rep.program           #=> "; p rep.program
  print "  rep.version           #=> "; p rep.version
  print "  rep.reference         #=> "; p rep.reference
  print "  rep.notice            #=> "; p rep.notice
  print "  rep.db                #=> "; p rep.db
  #print "  rep.query_id          #=> "; p rep.query_id
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  #puts
  print "  rep.version_number    #=> "; p rep.version_number
  print "  rep.version_date      #=> "; p rep.version_date
  puts

  print "# === Parameters\n"
  #puts
  print "  rep.parameters        #=> "; p rep.parameters
  puts
  #@#print "  rep.matrix            #=> "; p rep.matrix
  print "  rep.expect            #=> "; p rep.expect
  #print "  rep.inclusion         #=> "; p rep.inclusion
  #@#print "  rep.sc_match          #=> "; p rep.sc_match
  #@#print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch
  #@#print "  rep.gap_open          #=> "; p rep.gap_open
  #@#print "  rep.gap_extend        #=> "; p rep.gap_extend
  #print "  rep.filter            #=> "; p rep.filter
  #@#print "  rep.pattern           #=> "; p rep.pattern
  #print "  rep.entrez_query      #=> "; p rep.entrez_query
  #puts
  #@#print "  rep.pattern_positions  #=> "; p rep.pattern_positions
  puts

  print "# === Statistics (last iteration's)\n"
  #puts
  #print "  rep.statistics        #=> "; p rep.statistics
  puts
  print "  rep.db_num            #=> "; p rep.db_num
  print "  rep.db_len            #=> "; p rep.db_len
  #print "  rep.hsp_len           #=> "; p rep.hsp_len
  #@#print "  rep.eff_space         #=> "; p rep.eff_space
  #@#print "  rep.kappa             #=> "; p rep.kappa
  #@#print "  rep.lambda            #=> "; p rep.lambda
  #@#print "  rep.entropy           #=> "; p rep.entropy
  puts
  #@#print "  rep.num_hits          #=> "; p rep.num_hits
  #@#print "  rep.gapped_kappa      #=> "; p rep.gapped_kappa
  #@#print "  rep.gapped_lambda     #=> "; p rep.gapped_lambda
  #@#print "  rep.gapped_entropy    #=> "; p rep.gapped_entropy
  #@#print "  rep.posted_date       #=> "; p rep.posted_date
  puts

  #@#print "# === Message (last iteration's)\n"
  #@#puts
  #@#print "  rep.message           #=> "; p rep.message
  #puts
  #@#print "  rep.converged?        #=> "; p rep.converged?
  #puts

  print "# === Warning messages\n"
  print "  rep.warnings        #=> "; p rep.warnings

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
      
  print "# --- Bio::Blast::WU::Report::Iteration\n"
  puts

  print "    itr.num             #=> "; p itr.num
  #print "    itr.statistics      #=> "; p itr.statistics
  puts
  print "    itr.warnings        #=> "; p itr.warnings
  print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  #puts
  #@#print "    itr.hits_newly_found.size    #=> "; p itr.hits_newly_found.size;
  #@#print "    itr.hits_found_again.size    #=> "; p itr.hits_found_again.size;
  if itr.hits_for_pattern then
  itr.hits_for_pattern.each_with_index do |hp, hpi|
  print "    itr.hits_for_pattern[#{hpi}].size #=> "; p hp.size;
  end
  end
  print "    itr.converged?      #=> "; p itr.converged?
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each_with_index do |hit, i|

  print "# --- Bio::Blast::WU::Report::Hit"
  print " ([#{i}])\n"
  puts

  #print "      hit.num           #=> "; p hit.num
  #print "      hit.hit_id        #=> "; p hit.hit_id
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  #print "      hit.accession     #=> "; p hit.accession
  #puts
  print "      hit.found_again?  #=> "; p hit.found_again?
  #puts
  print "      hit.score         #=> "; p hit.score
  print "      hit.pvalue        #=> "; p hit.pvalue
  print "      hit.n_number      #=> "; p hit.n_number

  print "        --- compatible/shortcut ---\n"
  #print "      hit.query_id      #=> "; p hit.query_id
  #print "      hit.query_def     #=> "; p hit.query_def
  #print "      hit.query_len     #=> "; p hit.query_len
  #print "      hit.target_id     #=> "; p hit.target_id
  print "      hit.target_def    #=> "; p hit.target_def
  print "      hit.target_len    #=> "; p hit.target_len

  print "            --- first HSP's values (shortcut) ---\n"
  print "      hit.evalue        #=> "; p hit.evalue
  print "      hit.bit_score     #=> "; p hit.bit_score
  print "      hit.identity      #=> "; p hit.identity
  #print "      hit.overlap       #=> "; p hit.overlap

  print "      hit.query_seq     #=> "; p hit.query_seq
  print "      hit.midline       #=> "; p hit.midline
  print "      hit.target_seq    #=> "; p hit.target_seq

  print "      hit.query_start   #=> "; p hit.query_start
  print "      hit.query_end     #=> "; p hit.query_end
  print "      hit.target_start  #=> "; p hit.target_start
  print "      hit.target_end    #=> "; p hit.target_end
  print "      hit.lap_at        #=> "; p hit.lap_at
  print "            --- first HSP's vaules (shortcut) ---\n"
  print "        --- compatible/shortcut ---\n"

  puts
  print "      hit.hsps.size     #=> "; p hit.hsps.size
  if hit.hsps.size == 0 then
  puts  "          (HSP not found: please see blastall's -b and -v options)"
  puts
  else

  puts
  print "      hit.hsps.each do |hsp|\n"
  puts

  hit.hsps.each_with_index do |hsp, j|

  print "# --- Bio::Blast::WU::Report::Hsp"
  print " ([#{j}])\n"
  puts
  #print "        hsp.num         #=> "; p hsp.num
  print "        hsp.bit_score   #=> "; p hsp.bit_score 
  print "        hsp.score       #=> "; p hsp.score
  print "        hsp.evalue      #=> "; p hsp.evalue
  print "        hsp.identity    #=> "; p hsp.identity
  print "        hsp.gaps        #=> "; p hsp.gaps
  print "        hsp.positive    #=> "; p hsp.positive
  print "        hsp.align_len   #=> "; p hsp.align_len
  #print "        hsp.density     #=> "; p hsp.density
  puts
  print "        hsp.pvalue      #=> "; p hsp.pvalue
  print "        hsp.p_sum_n     #=> "; p hsp.p_sum_n
  puts

  print "        hsp.query_frame #=> "; p hsp.query_frame
  print "        hsp.query_from  #=> "; p hsp.query_from
  print "        hsp.query_to    #=> "; p hsp.query_to

  print "        hsp.hit_frame   #=> "; p hsp.hit_frame
  print "        hsp.hit_from    #=> "; p hsp.hit_from
  print "        hsp.hit_to      #=> "; p hsp.hit_to

  #print "        hsp.pattern_from#=> "; p hsp.pattern_from
  #print "        hsp.pattern_to  #=> "; p hsp.pattern_to

  print "        hsp.qseq        #=> "; p hsp.qseq
  print "        hsp.midline     #=> "; p hsp.midline
  print "        hsp.hseq        #=> "; p hsp.hseq
  puts
  print "        hsp.percent_identity  #=> "; p hsp.percent_identity
  #print "        hsp.mismatch_count    #=> "; p hsp.mismatch_count
  #
  print "        hsp.query_strand      #=> "; p hsp.query_strand
  print "        hsp.hit_strand        #=> "; p hsp.hit_strand
  print "        hsp.percent_positive  #=> "; p hsp.percent_positive
  print "        hsp.percent_gaps      #=> "; p hsp.percent_gaps
  puts

  end #each
  end #if hit.hsps.size == 0
  end
  end
  end #ff.each
  end #FlatFile.open

end #if __FILE__ == $0

######################################################################

=begin

= Bio::Blast::WU::Report

    WU-BLAST default output parser.
    It is still incomplete and may contain many bugs,
    because I don't have WU-BLAST license.
    It was tested under web-based WU-BLAST results and
    obsolete version downloaded from ((<URL:http://blast.wustl.edu/>)).

= Bio::Blast::WU::Report_TBlast

    WU-BLAST default output parser for TBLAST.
    All methods are equal to Bio::Blast::WU::Report.
    Only DELIMITER (and RS) is different.

= References

* ((<URL:http://blast.wustl.edu/>))
* ((<URL:http://www.ebi.ac.uk/blast2/>))

=end
