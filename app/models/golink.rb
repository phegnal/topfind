class Golink < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ancestor_id     :integer
    ancestor_type   :string
    descendant_id   :integer
    descendant_type :string
    direct          :boolean
    count           :integer
    timestamps
  end

  acts_as_dag_links :polymorphic => true


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
