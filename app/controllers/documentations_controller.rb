class DocumentationsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  index_actions :admin, :about, :license, :download, :api
  caches_page :index,:about,:license

  # def show
  # end
  #
  # def new
  # end
  #
  # def create
  # end
  #
  # def edit
  # end
  #
  # def update
  # end
  #
  # def destroy
  # end
  
  def index
  	hobo_index Documentation.show_is(1).order_by(:position)
  end
  
  def admin
  	hobo_index
  end
  
  def about
  	hobo_index
  end
  
  def license
  	hobo_index
  end
  
  def download
  	hobo_index
  end
  
  
  def api
    hobo_index
  end
  
  def updates
    hobo_index
  end  

end
