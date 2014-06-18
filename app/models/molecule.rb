class Molecule < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    formula     :string
    external_id :string
    source      :string
    timestamps
  end
  
  has_many :inhibitions
  has_many :proteases, :foreign_key => 'protease_id', :accessible => :true
  has_many :moleculenames  


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
