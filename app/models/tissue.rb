class Tissue < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    tsid :string
    ac   :string
    timestamps
  end

  def name
    tsid
  end
  
  has_many :tissuesynonymes
  
  has_many :evidence2tissues
  has_many :evidences, :through => :evidence2tissues
  

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
