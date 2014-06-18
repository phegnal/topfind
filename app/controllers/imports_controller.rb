class ImportsController < ApplicationController

  hobo_model_controller
  
  
  
  auto_actions :index, :create, :new

  def index
    if current_user.administrator?
  		@imports = Import.owner_id_not_nil
  		@evidences = Evidence.owner_id_not_nil
    else
  		@imports = Import.owner_is(current_user)
  		@evidences = Evidence.owner_is(current_user)
    end
  	hobo_index @imports
  end

  def create    
    if current_user.administrator? 	
    	hobo_create :redirect => '/topfind/contribute'
    	#@import.process_csv
    else
    	hobo_create :redirect => '/topfind/contribute'
    	UserMailer.deliver_new_submission(current_user,@import)
    	UserMailer.deliver_new_submission_confirmation(current_user,@import)
    end

  end

end
