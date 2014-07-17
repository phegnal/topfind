class Nterm < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    protein_id :integer
    pos        :integer
    seqexcerpt    :string, :index => :true
    idstring   :string, :unique
    timestamps
  end
  default_scope :order => 'pos ASC'

  has_many :chains
  has_many :cleavages
  belongs_to :isoform
  belongs_to :protein

  belongs_to :terminusmodification
 
  # has_many :evidencerelations, :as => :traceable
  # has_many :evidences, :through => :evidencerelations, :accessible => true    
  
  has_many :nterm2evidences
  has_many :evidences, :through => :nterm2evidences, :uniq => true   
  
  belongs_to :import


  after_create :map_to_isoforms
  
  def name
    self.idstring
  end
  
  def externalid
  	"TNt#{self.id}"
  end 
   
  def targeted_features
    self.protein.fts.spanning(self.pos-3,self.pos+4)
  end
  
  def modificationclass
  	name = ''
  	if self.terminusmodification.present?
  		name = self.terminusmodification.kw.name if self.terminusmodification.kw.present?
 	end
 	return name
  end
  
  def targeted_boundaries(type = 'match')
  	case type
  		when 'match' 
    		self.protein.fts.matchfrom(self.pos)
    	when 'lost'
    		self.protein.fts.matchto(self.pos-1)
	end
  end  

  def map_to_isoforms

  	#dont propagate entires derived from these databases
  	exclude = ['TopFIND','Ensembl','TISdb']
    unless exclude.include?(self.evidences.first.evidencesource.dbname)
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
	    :dburl => "http://clipserve.clip.ubc.ca/topfind/proteins/#{self.protein.ac}\##{self.externalid}"
	  ) 	
	  @isoevidence.evidencecodes << Evidencecode.find_or_create_by_name(:name => 'inferred from isoform by sequence similarity',																	:code => 'TopFIND:0000002')
	  @isoevidence.save

	  mapping = self.protein.isoform_crossmapping(self.pos,'right')
	  mapping.each_pair do |ac,pos|
	    matchprot = Protein.ac_is(ac).first
	  	nterm = Nterm.find_or_create_by_idstring(:idstring => "#{ac}-#{pos}-#{self.terminusmodification.name}",:protein_id => matchprot.id, :pos => pos, :terminusmodification => self.terminusmodification )
		nterm.evidences << @iso_evidence unless nterm.evidences.include?(@iso_evidence)
		matchprot.nterms << nterm unless matchprot.nterms.include?(nterm)
	  end
	end
  end



  def self.generate_csv(ids)
    FasterCSV.generate({:col_sep => "\t"}) do |csv|
      csv << ['topcat terminus id','position','sequence','protein (uniprot ac)','topcat evidence ids']
      ids.each do |id|
        n = Nterm.find(id)       
        csv << [n.externalid,n.pos,n.protein.sequence[n.pos-1..n.pos+9],n.protein.ac,n.evidences.*.externalid.join(':')]
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
