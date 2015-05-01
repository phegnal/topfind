class Evidencesource < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    dbid   :string
    dbname :string
    dburl  :string
    dbdesc :string
    timestamps
  end

  has_many :evidences
  
  def name
    self.dbname
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
