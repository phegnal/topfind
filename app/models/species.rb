class Species < ActiveRecord::Base
  hobo_model 
  fields do
    name :string, :required, :unique, :index => true
    common_name :string, :unique, :index => true
  end

  has_many :proteins  

  def view_permitted?(field)
    true
  end  
end