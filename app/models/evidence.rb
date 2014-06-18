class Evidence < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    idstring	   :string, :unique
    name           :string, :required, :index => true
    method         :string, :index => true
    method_system enum_string('cell free','cell culture','organ or tissue culture','in vivo sample','unknown'), :default => 'unknown', :index => true
    method_perturbation	:string, :index=> true, :default => ''
    method_protease_source enum_string('recombinant','natural expression','over expression','knockdown (expression)','genetic knockout','knockdown (functional, protease drug or blocking antibody or inhibitor used)','unknown'), :default => 'unknown', :index => true
    methodology enum_string('other','electronic annotation','COFRADIC','N-TAILS','C-TAILS','ATOMS','Subtiligase Based Positive Selection','Edman sequencing','enzymatic biotinylation','chemical biotinylatin','MS gel band','MS semi-tryptic peptide','MS other','mutation analysis','unknown'), :default => 'unknown', :index => true
    proteaseassignment_confidence enum_string('I no other proteolytic activities present', 'II proteolytic system present but abolished', 'III proteolytic system present but impaired', 'IV proteolytic system present and active','unknown'), :default => 'unknown', :index => true
    description    :text
    repository	   :string 
    lab            :string, :index => true
    phys_relevance enum_string('unknown','none','unlikely','likely','yes'), :default => 'unknown', :index => true
    directness     enum_string('unknown','direct','likely direct','likely indirect','indirect'), :default => 'unknown', :index => true
    protease_inhibitors_used :string
    confidence     :float, :default => nil
    confidence_type enum_string('unknown','probability','ProteinProspector','MASCOT score','X! Tandem score','PeptideProphet probability'), :default => 'unknown'
    timestamps
  end



  has_many :evidence2tissues
  has_many :tissues, :through => :evidence2tissues, :accessible => true, :uniq => true
  # has_many :evidence2cellines
  # has_many :celllines, :through => :evidence2cellines, :accessible => true
  has_many :evidence2gocomponents
  has_many :gocomponents, :through => :evidence2gocomponents, :accessible => true, :uniq => true 
  
  has_many :evidence2evidencecodes
  has_many :evidencecodes, :through => :evidence2evidencecodes, :foreign_key => :code, :accessible => true, :uniq => true   
  
  belongs_to :evidencesource, :accessible => true
  
  has_many :evidence2publications
  has_many :publications,  :through => :evidence2publications, :accessible => true, :dependent => :destroy, :uniq => true
  
  has_attached_file :evidencefile, :dependent => :destroy, :styles => {
    :thumb => ["50x50>", :png],
    :small => ["300x400>",:png],
    :large => ["900x900>",:png]
  }
  has_many :imports
  
  # has_many :evidencerelations
  # has_many :cleavages, :through => :evidencerelations , :source => :taceable, :source_type => 'Cleavage' 
  # has_many :nterms, :through => :evidencerelations, :source => :taceable, :source_type => 'Nterm'
  # has_many :cterms, :through => :evidencerelations, :source => :taceable, :source_type => 'Cterm'  
  # has_many :chains, :through => :evidencerelations, :source => :taceable, :source_type => 'Chain'   
  
  has_many :cleavage2evidences
  has_many :cleavages, :through => :cleavage2evidences
  has_many :inbibition2evidences
  has_many :inhibitions, :through => :inhibition2evidences
  has_many :cterm2evidences
  has_many :cterms, :through => :cterm2evidences
  has_many :nterm2evidences
  has_many :nterms, :through => :nterm2evidences
  has_many :chain2evidences
  has_many :chains, :through => :chain2evidences
  

  belongs_to :owner, :class_name => "User", :creator => true  
  

  before_post_process :process?

  def externalid
  	"TE#{self.id}"
  end

  def self.generate_csv(ids)
    FasterCSV.generate({:col_sep => "\t"}) do |csv|
      csv << ['topfind evidence id','name','method','description','lab','repository','physiological relevance','directness of detection','confidence','tissues','publications (PubMed id)','evidencecode names','evidencecodes']
      ids.each do |id|
        e = Evidence.find(id)       
        csv << [e.externalid,e.name,e.method,e.description,e.lab,e.repository,e.phys_relevance,e.directness,"#{e.confidence.to_s} #{e.confidence_type}",e.tissues.*.ac.join(':'),e.publications.*.pmid.join(':'),e.evidencecodes.*.name.join(':'),e.evidencecodes.*.code.join(':')]
      end
    end  
  end 


  def process?
    :image || :pdf
  end
  
  def image?
    !(evidencefile_content_type =~ /^image.*/).nil?
  end
  
  def pdf?
    !(evidencefile_content_type =~ /^application\/pdf.*/).nil?
  end


  # --- Permissions --- #

  def create_permitted?
    acting_user
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
