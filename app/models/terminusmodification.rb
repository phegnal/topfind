class Terminusmodification < ActiveRecord::Base

  hobo_model # Don't put anything above this
  require 'Ols'

  fields do
  	ac	        :string, :index => true
    name        :string, :index => true
    description :text
    nterm       :boolean, :default => false
    cterm       :boolean, :default => false
    subcell     :string
    psimodid	:string
    display     :boolean, :default => true
    timestamps
  end

  has_many :nterms
  has_many :cterms
  belongs_to :kw
  
  def category?
  	self.name == self.kw.name if self.kw
  end
  
  def self.inuse
  	tmods = Terminusmodification.with_cterms
  	tmods << Terminusmodification.with_nterms
  	tmods.flatten!
  	tmods.uniq!
  	return tmods
  end
  
  def self.kwgroup
  	kws = Terminusmodification.with_cterms.*.kw
  	kws << Terminusmodification.with_nterms.*.kw
  	kws.flatten!
  	kws.delete(nil)
  	kws.uniq!
  	return kws
  end
  
  def ols_definition
  	if psimodid.present?
  		ols = Ols.identifier_is(psimodid).first
  		ols.present? ? definition = ols.definition : defininition =  ""
    else
    	definition = ""
    end
    return definition
  end
  
  def psimodlink
  	if psimodid.present?
  		"<a href='http://www.ebi.ac.uk/ontology-lookup/?termId=#{psimodid}' target='_blank'>#{psimodid}</a>"
  	else
  		""
  	end
  end
  
  def publications
    if self.psimodid
  		pmids = Ols_dbxref.parent_pk_is("#{self.psimodid}MOD1").pubmed.*.accession
	else
		pmids = []
  	end
  	pubs = []
  	pubs = pmids.map {|pmid| Publication.find_or_create_by_pmid(pmid)} 
  	
  	pubs	
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
