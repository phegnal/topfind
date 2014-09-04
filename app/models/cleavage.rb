class Cleavage < ActiveRecord::Base

  hobo_model # Don't put anything above this

  
  fields do
    idstring          :string, :unique
    pos               :integer #pos is defined as the p1 position
    peptide           :string
    timestamps
  end  
  default_scope :order => 'pos ASC'
  
  belongs_to :protease, :class_name => 'Protein', :foreign_key =>'protease_id'
  belongs_to :substrate, :class_name => 'Protein', :foreign_key =>'substrate_id'
  
  belongs_to :proteaseisoform, :class_name => 'Isoform', :foreign_key => 'proteaseisoform_id'
  belongs_to :proteasechain, :class_name => 'Chain', :foreign_key => 'proteasechain_id'
  
  belongs_to :substrateisoform, :class_name => 'Isoform', :foreign_key => 'substrateisoform_id'
  belongs_to :substratechain, :class_name => 'Chain', :foreign_key => 'substratechain_id'
  
  belongs_to :cleavagesite
  
  belongs_to :cterm, :accessible => true, :dependent => :destroy
  belongs_to :nterm, :accessible => true, :dependent => :destroy
   
  # has_many :evidencerelations, :as => :traceable
  # has_many :evidences, :through => :evidencerelations, :accessible => true    
  
  has_many :cleavage2evidences
  has_many :evidences, :through => :cleavage2evidences, :uniq => true
  
  
  belongs_to :import

  def name 
    if substrate
      name = protease.name+' > '+substrate.name+' @ '+pos.to_s
    else
      name = "#{protease.name} "
    end
    name
  end

  def externalid
  	"TC#{self.id}"
  end

  def protease_name
    protease.name if protease
  end
  
  def protease_name=(name)
    self.protease = Protein.find_by_name(name) unless name.blank?
  end

  def substrate_name
    substrate.name if substrate
  end
  
  def substrate_name=(name)
    self.substrate = Protein.find_by_name(name) unless name.blank?
  end
  
  def targeted_features
    substrate ? self.substrate.fts.spanning(self.pos-3,self.pos+4) : []
  end
  
  def targeted_boundaries
    substrate ? self.substrate.fts.matching(self.pos).concat(self.substrate.fts.matching(self.pos+1)) : []
  end
  
  def process_cleavagesite
    nonprimeseq = Array.new
    primeseq = Array.new
    if self.pos && self.substrate_id
      #pick appropriate sequence from base protein entry or isoform
      if self.substrateisoform.nil?
        seq = self.substrate.sequence
      else
        seq = self.substrateisoform.sequence
      end
      
      #convert sequence string into array of single as, prepend with empty as for array index 0
      seqarray = seq.split(//).unshift('')
      
      #define the start of the nonprime sequence as pos-1 or 0 if pos-1 < 0
      # self.pos-1 << 0 ? nonprime_start = 0 : nonprime_start = self.pos-1
      
      primeseq = seqarray[self.pos+1..self.pos+11]
      nonprimeseq = seqarray[1..self.pos].reverse[0..9]
    elsif peptide
      peptide.split(':')[1] ? primeseq = peptide.split(':')[1] : primeseq = ''
      nonprimeseq = peptide.split(':')[0]
      primeseq = primeseq.split(//)[0..9]
      nonprimeseq = nonprimeseq.split(//).reverse[0..9]
    end
    if primeseq && nonprimeseq 
      idstring = "#{nonprimeseq.reverse.to_s}-#{primeseq}"
      cleavagesite = Cleavagesite.find_or_create_by_idstring(
        :idstring => idstring,
        :p10 => nonprimeseq[9],
        :p9 => nonprimeseq[8],
        :p8 => nonprimeseq[7],
        :p7 => nonprimeseq[6],
        :p6 => nonprimeseq[5],
        :p5 => nonprimeseq[4],
        :p4 => nonprimeseq[3],
        :p3 => nonprimeseq[2],
        :p2 => nonprimeseq[1],
        :p1 => nonprimeseq[0],
        :p1p => primeseq[0],
        :p2p => primeseq[1],
        :p3p => primeseq[2],
        :p4p => primeseq[3],
        :p5p => primeseq[4],
        :p6p => primeseq[5],
        :p7p => primeseq[6],
        :p8p => primeseq[7],
        :p9p => primeseq[8],
        :p10p => primeseq[9]
        )
        
      self.update_attributes(:cleavagesite => cleavagesite)  
    end
  end
  
  def process_termini
      if substrate
        #get all evidences for the cleavage, modify to reflect indirectness, add to c and nterm
        puts evidences
        self.evidences.each do |e|
          @newevidence =  Evidence.find_or_create_by_idstring(
          	:idstring => "inferred-cleavage-#{self.externalid}",
              :name => "Inferred from cleavage #{self.externalid}",
              :description => "Inferred from cleavage #{e.name}:\n#{e.description}",
              :phys_relevance => "unknown",
              :directness => 'indirect',
      		:method => 'electronic annotation'
           )
           @newevidence.evidencesource = Evidencesource.find_or_create_by_dbid(
              :dbname => "TopFIND",
              :dbid => self.externalid,
              :dburl => "http://clipserve.clip.ubc.ca/topfind/proteins/#{self.substrate.ac}\##{self.externalid}"
            )   
           @newevidence.evidencecodes << Evidencecode.find_or_create_by_name(:name => 'inferred from cleavage',
      																	  :code => 'TopFIND:0000001')
      	   @newevidence.save
      	   
			if pos.to_i-1 >= 2
				ct_idstring = "#{substrate.ac}-#{pos}-unknown"
				puts ct_idstring
				cterm = self.cterm = Cterm.find_or_create_by_idstring(
				  :idstring => ct_idstring,  
				  :protein => self.substrate,
				  :isoform => self.substrateisoform,
				  :pos => pos-1,
				  :terminusmodification => Terminusmodification.find_or_create_by_name('unknown'))
			  
			   cterm.evidences.include?(@newevidence) ? 1 : cterm.evidences << @newevidence
			end

			if pos.to_i <= self.substrate.aalen.to_i-2
				nt_idstring = "#{substrate.ac}-#{pos+1}-unknown"
				nterm = self.nterm = Nterm.find_or_create_by_idstring(
				  :idstring => nt_idstring,  
				  :protein => self.substrate,
				  :isoform => self.substrateisoform,
				  :pos => pos,
				  :terminusmodification => Terminusmodification.find_or_create_by_name('unknown'))
			  
			   nterm.evidences.include?(@newevidence) ? 1 : nterm.evidences << @newevidence
			end
         end
      end
  end
  

  def map_to_isoforms
      mapping = self.substrate.isoform_crossmapping(self.pos,'centre') if self.substrate.present?
      
      if mapping.present?  
		  #generate "inferred from isoform" evidence
		  @isoevidence = Evidence.find_or_create_by_name(:name => "inferred from #{self.externalid}",
			:idstring => "inferred-isoform-#{self.externalid}",
			:description => 'The stated informations has been inferred from an isoform by sequence similarity at the stated position.',
			:phys_relevance => "unknown",
			:directness => 'indirect',
			:method => 'electronic annotation'
		  )
		  @isoevidence.evidencesource = Evidencesource.find_or_create_by_dbid(
			:dbname => "TopFIND",
			:dbid => self.externalid,
			:dburl => "http://clipserve.clip.ubc.ca/topfind/proteins/#{self.substrate.ac}\##{self.externalid}"
		  ) 	
		  @isoevidence.evidencecodes << Evidencecode.find_or_create_by_name(:name => 'inferred from isoform by sequence similarity',																	:code => 'TopFIND:0000002')
		  @isoevidence.save
	  
		  mapping.each_pair do |ac,pos|
			matchprot = Protein.ac_is(ac).first
			idstring = "P(#{self.protease.ac})-S(#{ac})at(#{pos})"
			cleavage = Cleavage.find_or_create_by_idstring(
				:idstring => idstring,
				:protease_id => self.protease.id,
				:substrate_id => matchprot.id,
				:peptide => self.peptide,
				:pos => pos
			  )
			cleavage.evidences << @isoevidence unless cleavage.evidences.include?(@isoevidence)
			matchprot.inverse_cleavages << cleavage unless matchprot.inverse_cleavages.include?(cleavage)
		  end
	   end
  end

  def self.generate_csv(ids)
    FasterCSV.generate({:col_sep => "\t"}) do |csv|
      csv << ['topcat cleavage id','protease (uniprot ac)','substrate (uniprot ac)','p1 position','topcat evidence ids']
      ids.each do |id|
        c = Cleavage.find(id)       
        csv << [c.externalid,c.protease.ac,c.substrate.ac,c.pos,c.evidences.*.externalid.join(':')] if c.protease.present? && c.substrate.present?
      end
    end  
  end 

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
