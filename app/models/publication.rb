class Publication < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    pmid     :integer, :required
    title    :string
    authors  :text
    abstract :text
    ref      :string  
    doi      :string
    url      :string
    timestamps
  end

  has_many :evidence2publications
  has_many :evidences, :through => :evidence2publications, :uniq => true
  # belongs_to :protein  

  before_save :retrieve_medline

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


  def retrieve_medline
    require 'bio'
    
    # retrieve record from pubmed
    Bio::NCBI.default_email = "plange@interchange.ubc.ca"    
    pubmed = Bio::MEDLINE.new(Bio::PubMed.efetch(self.pmid).first)
    
    self.title = pubmed.ti
    self.authors = pubmed.au.gsub(/\n/,', ') #replace newlines by ,
    self.abstract = pubmed.ab
    self.ref = pubmed.so
    self.doi = ''
    aidarray = pubmed.instance_variable_get(:@pubmed)['AID'].to_a
    aidarray.each do |id|
    	if id.include?('[doi]')
    		self.doi = id.gsub(/^(.*)+\[doi\]/,'\1') 
    	end
    end
    self.doi.length > 5 ? self.url = "http://dx.doi.org/#{self.doi}" : self.url = ''
  end
    

end
