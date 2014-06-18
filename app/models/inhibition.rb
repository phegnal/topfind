class Inhibition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do 
    idstring :string, :unique  
    timestamps
  end 
    
  belongs_to :inhibited_protease, :foreign_key => 'inhibited_protease_id', :class_name => 'Protein'
  belongs_to :inhibitor, :class_name => 'Protein'
  
  belongs_to :inhibited_proteaseisoform, :class_name => 'Isoform', :foreign_key => 'inhibited_proteaseisoform_id'
  belongs_to :inhibited_proteasechain, :class_name => 'Chain', :foreign_key => 'inhibited_proteasechain_id'
  
  belongs_to :inhibitorisoform, :class_name => 'Isoform', :foreign_key => 'inhibitorisoform_id'
  belongs_to :inhibitorchain, :class_name => 'Chain', :foreign_key => 'inhibitorchain_id' 
  
  # Small molecule inhibitors
  belongs_to :molecule
  belongs_to :inhibitory_molecule, :class_name => 'Molecule'   
  
  
  has_many :inhibition2evidences
  has_many :evidences, :through => :inhibition2evidences, :uniq => true  

  
  belongs_to :import

  def name 
    name = inhibitor.name+' --| '+inhibited_protease.name if inhibitor
    # name = inhibitory_molecule.name+' --| '+inhibited_protease.name if inhibitory_molecule
    
    name
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
