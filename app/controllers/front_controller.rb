class FrontController < ApplicationController

  hobo_controller
  caches_page :index
  
  
  def index
    @documentations = Documentation.all.group_by(&:name)
 
  end



end
