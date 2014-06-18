class Chain < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    idstring    :string, :unique
    name        :string
    description :text
    from        :integer
    to          :integer
    timestamps
  end

  belongs_to :protein
  belongs_to :isoform
  
  has_many :cleavages, :foreign_key => 'proteasechain_id', :accessible => true
  has_many :substrates, :through => :cleavages
  has_many :inverse_cleavages, :class_name => "Cleavage", :foreign_key => "substratechain_id", :accessible => true
  has_many :proteases, :through => :inverse_cleavages 
  
  belongs_to :cterm
  belongs_to :nterm     

 
  # has_many :evidencerelations, :as => :traceable
  # has_many :evidences, :through => :evidencerelations, :accessible => true    
  
  has_many :chain2evidences
  has_many :evidences, :through => :chain2evidences
    
  has_many :fts, :through => :protein


  def htmlsequence
    self.protein.sequence.gsub(/(.{5})/,'\1 ')
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
