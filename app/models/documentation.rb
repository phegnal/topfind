class Documentation < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name     :string
    title    :string
    long     :text
    short    :text
    category :string
    position :integer, :default => 0
    show     :boolean, :default => false
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
