class Cterm < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    pos           :integer
    idstring      :string, :unique
    seqexcerpt    :string, :index => :true
    timestamps
  end

  default_scope :order => 'pos ASC'


  has_many :chains
  has_many :cleavages
  belongs_to :isoform
  belongs_to :protein

  belongs_to :terminusmodification
  
  belongs_to :import  
   
 
  # has_many :evidencerelations, :as => :traceable
  # has_many :evidences, :through => :evidencerelations, :accessible => true    
  
  has_many :cterm2evidences
  has_many :evidences, :through => :cterm2evidences, :uniq => true

  after_create :map_to_isoforms

  def name
    "#{protein.name}-#{pos.to_s} (#{terminusmodification.name})"
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
    		self.protein.fts.matchto(self.pos)
    	when 'lost'
    		self.protein.fts.matchfrom(self.pos+1)
	end
  end         

  def map_to_isoforms
	@iso_evidence = Evidence.name_is('inferred from isoform').first

    unless self.evidences.count == 1 && self.evidences.include?(@iso_evidence)
	  mapping = self.protein.isoform_crossmapping(self.pos,'left')
	  puts mapping
	  mapping.each_pair do |ac,pos|
	    matchprot = Protein.ac_is(ac).first
	  	cterm = Cterm.find_or_create_by_idstring(:idstring => "#{ac}-#{pos}-#{self.terminusmodification.name}",:protein_id => matchprot.id, :pos => pos, :terminusmodification => self.terminusmodification )
		cterm.evidences << @iso_evidence unless cterm.evidences.include?(@iso_evidence)
		matchprot.cterms << cterm unless matchprot.cterms.include?(cterm)
	  end
	end
  end


 def self.generate_csv(ids)
    FasterCSV.generate({:col_sep => "\t"}) do |csv|
      csv << ['topcat terminus id','position','sequence','protein (uniprot ac)','topcat evidence ids']
      ids.each do |id|
        c = Cterm.find(id)       
        csv << [c.externalid,c.pos,c.protein.sequence[c.pos-10..c.pos-1],c.protein.ac,c.evidences.*.externalid.join(':')]
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
