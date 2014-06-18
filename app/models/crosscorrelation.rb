class Crosscorrelation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    id            :integer
    name          :string
    email         :string
    desc          :text
    ntermini      :text
    ctermini      :text
    cleavagesites :text
    ip            :string
    timestamps
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
