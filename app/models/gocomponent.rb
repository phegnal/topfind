class Gocomponent < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    acc         :string
    name        :string
    description :text
    is_obsolete :boolean
    timestamps
  end
   
  has_dag_links :link_class_name => 'Golink', :ancestor_class_names => ['Gofunction','Goprocess','Gocomponent'], :descendant_class_names => ['Gofunction','Goprocess','Gocomponent']
  

  has_many :evidence2tissues
  has_many :tissues, :through => :evidence2tissues


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
