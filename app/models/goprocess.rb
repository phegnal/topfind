class Goprocess < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    acc         :string
    name        :string
    description :text
    is_obsolete :boolean
    timestamps
  end

  has_dag_links :link_class_name => 'Golink', :ancestor_class_names => ['Goprocess'], :descendant_class_names => ['Goprocess']


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
