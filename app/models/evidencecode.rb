class Evidencecode < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    code       :string
    name       :string
    definition :text
    timestamps
  end

  has_many :evidence2evidencecodes
  has_many :evidences, :through => :evidence2evidencecodes 

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
